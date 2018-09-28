# frozen_string_literal: true

require 'pathname'

require_relative 'config/version'

module TTY
  class Config
    # Error raised when key fails validation
    ReadError = Class.new(StandardError)
    # Error raised when issues writing configuration to a file
    WriteError = Class.new(StandardError)
    # Erorrr raised when setting unknown file extension
    UnsupportedExtError = Class.new(StandardError)
    # Error raised when validation assertion fails
    ValidationError = Class.new(StandardError)

    def self.coerce(hash, &block)
      new(normalize_hash(hash), &block)
    end

    # Convert string keys via method
    #
    # @api private
    def self.normalize_hash(hash, method = :to_sym)
      hash.reduce({}) do |acc, (key, val)|
        value = val.is_a?(::Hash) ? normalize_hash(val, method) : val
        acc[key.public_send(method)] = value
        acc
      end
    end

    # Storage for suppported format & extensions pairs
    # @api public
    EXTENSIONS = {
      yaml: %w(.yaml .yml),
      json: %w(.json),
      toml: %w(.toml),
      ini: %w(.ini .cnf .conf .cfg .cf)
    }

    # A collection of config paths
    # @api public
    attr_reader :location_paths

    # The key delimiter used for specifying deeply nested keys
    # @api public
    attr_reader :key_delim

    # The name of the configuration file without extension
    # @api public
    attr_accessor :filename

    # The name of the configuration file extension
    # @api public
    attr_reader :extname

    # The validations for this configuration
    # @api public
    attr_reader :validators

    # The prefix used for searching ENV variables
    # @api public
    attr_accessor :env_prefix

    def initialize(settings = {})
      @settings = settings
      @location_paths = []
      @validators = {}
      @filename = 'config'
      @extname = '.yml'
      @extensions = EXTENSIONS.values.reduce([]) { |acc, v| acc.concat(v); acc }
      @key_delim = '.'
      @envs = {}
      @env_prefix = ''
      @env_autoload = false

      yield(self) if block_given?
    end

    # Set extension name
    #
    # @raise [TTY::Config::UnsupportedExtError]
    #
    # api public
    def extname=(name)
      unless @extensions.include?(name)
        raise UnsupportedExtError, "Config file format `#{name}` is not supported."
      end
      @extname = name
    end

    # Add path to locations to search in
    #
    # @api public
    def append_path(path)
      @location_paths << path
    end

    # Insert location path at the begining
    #
    # @api public
    def prepend_path(path)
      @location_paths.unshift(path)
    end

    # Check if env variables are auto loaded
    #
    # @api public
    def env_autoload?
      @env_autoload == true
    end

    # Auto load env variables
    #
    # @api public
    def env_autoload
      @env_autoload = true
    end

    # Set a value for a composite key and overrides any existing keys.
    # Keys are case-insensitive
    #
    # @api public
    def set(*keys, value: nil, &block)
      assert_either_value_or_block(value, block)

      keys = convert_to_keys(keys)
      key = flatten_keys(keys)
      value_to_eval = block || value

      if validators.key?(key)
        if callable_without_params?(value_to_eval)
          value_to_eval = delay_validation(key, value_to_eval)
        else
          assert_valid(key, value)
        end
      end

      deepest_setting = deep_set(@settings, *keys[0...-1])
      deepest_setting[keys.last] = value_to_eval
      deepest_setting[keys.last]
    end

    # Set a value for a composite key if not present already
    #
    # @param [Array[String|Symbol]] keys
    #   the keys to set value for
    #
    # @api public
    def set_if_empty(*keys, value: nil, &block)
      return unless deep_find(@settings, keys.last.to_s).nil?
      block ? set(*keys, &block) : set(*keys, value: value)
    end

    # Bind a key to ENV variable
    #
    # @example
    #   set_env(:host)
    #   set_env(:foo, :bar) { 'HOST' }
    #
    # @param [Array[String]] keys
    #   the keys to bind to ENV variables
    #
    # @api public
    def set_env(*keys, &block)
      assert_keys_with_block(convert_to_keys(keys), block)
      key = flatten_keys(keys)
      env_key = block.nil? ? key : block.()
      env_key = to_env_key(env_key)
      @envs[key.to_s.downcase] = env_key
    end

    # Convert config key to standard ENV var name
    #
    # @param [String] key
    #
    # @api private
    def to_env_key(key)
      env_key = key.to_s.upcase
      @env_prefix == '' ? env_key : @env_prefix.to_s.upcase + "_" + env_key
    end

    # Fetch value under a composite key
    #
    # @param [Array[String|Symbol]] keys
    #   the keys to get value at
    # @param [Object] default
    #
    # @api public
    def fetch(*keys, default: nil, &block)
      keys = convert_to_keys(keys)
      env_key = env_autoload? ? to_env_key(keys[0]) : @envs[flatten_keys(keys)]
      # first try settings
      value = deep_fetch(@settings, *keys)
      # then try ENV var
      if value.nil? && env_key
        value = ENV[env_key]
      end
      # then try default
      value = block || default if value.nil?

      while callable_without_params?(value)
        value = value.call
      end
      value
    end

    # Merge in other configuration settings
    #
    # @param [Hash[Object]] other_settings
    #
    # @api public
    def merge(other_settings)
      @settings = deep_merge(@settings, other_settings)
    end

    # Append values to an already existing nested key
    #
    # @param [Array[String|Symbol]] values
    #   the values to append
    #
    # @api public
    def append(*values, to: nil)
      keys = Array(to)
      set(*keys, value: Array(fetch(*keys)) + values)
    end

    # Remove a set of values from a nested key
    #
    # @param [Array[String|Symbol]] keys
    #   the keys for a value removal
    #
    # @api public
    def remove(*values, from: nil)
      keys = Array(from)
      set(*keys, value: Array(fetch(*keys)) - values)
    end

    # Delete a value from a nested key
    #
    # @param [Array[String|Symbol]] keys
    #   the keys for a value deletion
    #
    # @api public
    def delete(*keys)
      keys = convert_to_keys(keys)
      deep_delete(*keys, @settings)
    end

    # Register validation for a nested key
    #
    # @api public
    def validate(*keys, &validator)
      key = flatten_keys(keys)
      values = validators[key] || []
      values << validator
      validators[key] = values
    end

    # Check if key passes all registered validations
    #
    # @api private
    def assert_valid(key, value)
      validators[key].each do |validator|
        validator.call(key, value)
      end
    end

    # Delay key validation
    #
    # @api private
    def delay_validation(key, callback)
      -> do
        val = callback.()
        assert_valid(key, val)
        val
      end
    end

    # @api private
    def find_file
      @location_paths.each do |location_path|
        path = search_in_path(location_path)
        return path if path
      end
      nil
    end
    alias source_file find_file

    # Check if configuration file exists
    #
    # @return [Boolean]
    #
    # @api public
    def persisted?
      !find_file.nil?
    end

    # Find and read a configuration file.
    #
    # If the file doesn't exist or if there is an error loading it
    # the TTY::Config::ReadError will be raised.
    #
    # @param [String] file
    #   the path to the configuration file to be read
    #
    # @raise [TTY::Config::ReadError]
    #
    # @api public
    def read(file = find_file)
      if file.nil?
        raise ReadError, "No file found to read configuration from!"
      elsif !::File.exist?(file)
        raise ReadError, "Configuration file `#{file}` does not exist!"
      end

      merge(unmarshal(file))
    end

    # Write current configuration to a file.
    #
    # @param [String] file
    #   the path to a file
    #
    # @api public
    def write(file = find_file, force: false)
      if file && ::File.exist?(file)
        if !force
          raise WriteError, "File `#{file}` already exists. " \
                            "Use :force option to overwrite."
        elsif !::File.writable?(file)
          raise WriteError, "Cannot write to #{file}."
        end
      end

      if file.nil?
        dir = @location_paths.empty? ? Dir.pwd : @location_paths.first
        file = ::File.join(dir, "#{filename}#{@extname}")
      end

      marshal(file, @settings)
    end

    # Current configuration
    #
    # @api public
    def to_hash
      @settings.dup
    end
    alias to_h to_hash

    private

    def callable_without_params?(object)
      object.respond_to?(:call) &&
        (!object.respond_to?(:arity) || object.arity.zero?)
    end

    def assert_keys_with_block(keys, block)
      if keys.size > 1 && block.nil?
        raise ArgumentError, "Need to set env var in block"
      end
    end

    def assert_either_value_or_block(value, block)
      if value.nil? && block.nil?
        raise ArgumentError, "Need to set either value or block"
      elsif !(value.nil? || block.nil?)
        raise ArgumentError, "Can't set both value and block"
      end
    end

    # Set value under deeply nested keys
    #
    # The scan starts with the top level key and follows
    # a sequence of keys. In case where intermediate keys do
    # not exist, a new hash is created.
    #
    # @param [Hash] settings
    #
    # @param [Array[Object]]
    #   the keys to nest
    #
    # @api private
    def deep_set(settings, *keys)
      return settings if keys.empty?
      key, *rest = *keys
      value = settings[key]

      if value.nil? && rest.empty?
        settings[key] = {}
      elsif value.nil? && !rest.empty?
        settings[key] = {}
        deep_set(settings[key], *rest)
      else # nested hash value present
        settings[key] = value
        deep_set(settings[key], *rest)
      end
    end

    def deep_find(settings, key, found = nil)
      if settings.respond_to?(:key?) && settings.key?(key)
        settings[key]
      elsif settings.is_a?(Enumerable)
        settings.each { |obj| found = deep_find(obj, key) }
        found
      end
    end

    def convert_to_keys(keys)
      first_key = keys[0]
      if first_key.to_s.include?(key_delim)
        first_key.split(key_delim)
      else
        keys.map(&:to_s)
      end
    end

    def flatten_keys(keys)
      first_key = keys[0]
      if first_key.to_s.include?(key_delim)
        first_key
      else
        keys.join(key_delim)
      end
    end

    # Fetch value under deeply nested keys with indiffernt key access
    #
    # @param [Hash] settings
    #
    # @param [Array[Object]] keys
    #
    # @api private
    def deep_fetch(settings, *keys)
      key, *rest = keys
      value = settings.fetch(key.to_s, settings[key.to_sym])
      if value.nil? || rest.empty?
        value
      else
        deep_fetch(value, *rest)
      end
    end

    # @api private
    def deep_merge(this_hash, other_hash,  &block)
      this_hash.merge(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(::Hash) && other_val.is_a?(::Hash)
          deep_merge(this_val, other_val, &block)
        elsif block_given?
          block[key, this_val, other_val]
        else
          other_val
        end
      end
    end

    # @api private
    def deep_delete(*keys, settings)
      key, *rest = keys
      value = settings[key]
      if !value.nil? && value.is_a?(::Hash)
        deep_delete(*rest, value)
      elsif !value.nil?
        settings.delete(key)
      end
    end

    # @api private
    def search_in_path(path)
      path = Pathname.new(path)
      @extensions.each do |ext|
        if ::File.exist?(path.join("#{filename}#{ext}").to_s)
          return path.join("#{filename}#{ext}").to_s
        end
      end
      nil
    end

    # @api private
    def unmarshal(file)
      ext = ::File.extname(file)
      self.extname = ext
      self.filename = ::File.basename(file, ext)

      case ext
      when *EXTENSIONS[:yaml]
        load_read_dep('yaml', ext)
        if YAML.respond_to?(:safe_load)
          YAML.safe_load(File.read(file))
        else
          YAML.load(File.read(file))
        end
      when *EXTENSIONS[:json]
        load_read_dep('json', ext)
        JSON.parse(File.read(file))
      when *EXTENSIONS[:toml]
        load_read_dep('toml', ext)
        TOML.load(::File.read(file))
      when *EXTENSIONS[:ini]
        load_read_dep('inifile', ext)
        ini = IniFile.load(file).to_h
        global = ini.delete('global')
        ini.merge!(global)
      else
        raise ReadError, "Config file format `#{ext}` is not supported."
      end
    end

    # Try loading read dependency
    # @api private
    def load_read_dep(gem_name, ext)
      require gem_name
    rescue LoadError
      puts "Please install `#{gem_name}`"
      raise ReadError, "Gem `#{gem_name}` is missing. Please install it " \
                       "to read #{ext} configuration format."
    end

    # @api private
    def marshal(file, data)
      ext = ::File.extname(file)
      self.extname = ext
      self.filename = ::File.basename(file, ext)

      case ext
      when *EXTENSIONS[:yaml]
        load_write_dep('yaml', ext)
        ::File.write(file, YAML.dump(self.class.normalize_hash(data, :to_s)))
      when *EXTENSIONS[:json]
        load_write_dep('json', ext)
        ::File.write(file, JSON.pretty_generate(data))
      when *EXTENSIONS[:toml]
        load_write_dep('toml', ext)
        ::File.write(file, TOML::Generator.new(data).body)
      else
        raise WriteError, "Config file format `#{ext}` is not supported."
      end
    end

    # Try loading write depedency
    # @api private
    def load_write_dep(gem_name, ext)
      require gem_name
    rescue LoadError
      puts "Please install `#{gem_name}`"
      raise ReadError, "Gem `#{gem_name}` is missing. Please install it " \
                       "to read #{ext} configuration format."
    end
  end # Config
end # TTY
