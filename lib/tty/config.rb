# frozen_string_literal: true

require "pathname"

require_relative "config/version"
require_relative "config/marshallers"
require_relative "config/marshallers/ini_marshaller"
require_relative "config/marshallers/json_marshaller"
require_relative "config/marshallers/yaml_marshaller"
require_relative "config/marshallers/toml_marshaller"
require_relative "config/marshallers/hcl_marshaller"
require_relative "config/marshallers/java_props_marshaller"
require_relative "config/marshallers/xml_marshaller"

module TTY
  # Responsible for managing application configuration
  #
  # @api public
  class Config
    include Marshallers

    # Error raised when failed to load a dependency
    DependencyLoadError = Class.new(StandardError)
    # Error raised when key fails validation
    ReadError = Class.new(StandardError)
    # Error raised when issues writing configuration to a file
    WriteError = Class.new(StandardError)
    # Erorrr raised when setting unknown file extension
    UnsupportedExtError = Class.new(StandardError)
    # Error raised when validation assertion fails
    ValidationError = Class.new(StandardError)
    # Error raised when told to prefer an unrecognized source
    UnsupportedSource = Class.new(StandardError)

    # Coerce a hash object into Config instance
    #
    # @return [TTY::Config]
    #
    # @api private
    def self.coerce(hash, &block)
      new(normalize_hash(hash), &block)
    end

    # Convert string keys via method
    #
    # @param [Hash] hash
    #   the hash to normalize keys for
    # @param [Symbol] method
    #   the method to use for converting keys
    #
    # @return [Hash{Symbol => Object}]
    #   the converted hash
    #
    # @api private
    def self.normalize_hash(hash, method = :to_sym)
      hash.each_with_object({}) do |(key, val), acc|
        value = val.is_a?(::Hash) ? normalize_hash(val, method) : val
        acc[key.public_send(method)] = value
      end
    end

    def self.normalize_preferred(source)
      case source.to_sym
      when :settings, :configuration, :config, :file, :files
        :settings
      when :environment, :env, :ENV
        :environment
      else
        raise UnsupportedSource, "Preferred Source `#{source}` is not supported."
      end
    end

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

    # The string used to separate parts in ENV variable name
    # @api public
    attr_accessor :env_separator

    # The preferred source for settings
    # @api public
    attr_reader :preferred

    # Set the preferred source for settings
    # @api public
    def preferred=(source)
      @preferred = self.class.normalize_preferred(source)
    end

    alias_method :prefer, :preferred=

    # Create a configuration instance
    #
    # @api public
    def initialize(settings = {})
      @settings = settings
      @location_paths = []
      @validators = {}
      @filename = "config"
      @extname = ".yml"
      @key_delim = "."
      @envs = {}
      @env_prefix = ""
      @env_separator = "_"
      @autoload_env = false
      @aliases = {}
      self.preferred = :settings

      register_marshaller :yaml, Marshallers::YAMLMarshaller
      register_marshaller :json, Marshallers::JSONMarshaller
      register_marshaller :toml, Marshallers::TOMLMarshaller
      register_marshaller :ini, Marshallers::INIMarshaller
      register_marshaller :xml, Marshallers::XMLMarshaller
      register_marshaller :hcl, Marshallers::HCLMarshaller
      register_marshaller :jprops, Marshallers::JavaPropsMarshaller

      yield(self) if block_given?
    end

    # Set extension name
    #
    # @raise [TTY::Config::UnsupportedExtError]
    #
    # api public
    def extname=(name)
      unless extensions.include?(name)
        raise UnsupportedExtError, "Config file format `#{name}` is not supported."
      end

      @extname = name
    end

    # Add path to locations to search in
    #
    # @example
    #   append_path(Dir.pwd)
    #
    # @param [String] path
    #   the path to append
    #
    # @return [Array<String>]
    #
    # @api public
    def append_path(path)
      @location_paths << path
    end

    # Insert location path at the begining
    #
    # @example
    #   prepend_path(Dir.pwd)
    #
    # @param [String] path
    #   the path to prepend
    #
    # @return [Array<String>]
    #
    # @api public
    def prepend_path(path)
      @location_paths.unshift(path)
    end

    # Check if env variables are auto loaded
    #
    # @return [Boolean]
    #
    # @api public
    def autoload_env?
      @autoload_env == true
    end

    # Auto load env variables
    #
    # @api public
    def autoload_env
      @autoload_env = true
    end

    # Set a value for a composite key and overrides any existing keys
    # Keys are case-insensitive
    #
    # @example
    #   set(:foo, :bar, :baz, value: 2)
    #
    # @example
    #   set(:foo, :bar, :baz) { 2 }
    #
    # @example
    #   set("foo.bar.baz", value: 2)
    #
    # @param [Array<String, Symbol>, String] keys
    #   the nested key to set value for
    # @param [Object] value
    #   the value to set
    #
    # @return [Object]
    #   the set value
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
    # @example
    #   set_if_empty(:foo, :bar, :baz, value: 2)
    #
    # @param [Array<String, Symbol>] keys
    #   the keys to set value for
    # @param [Object] value
    #   the value to set
    #
    # @return [Object, nil]
    #   the set value or nil
    #
    # @api public
    def set_if_empty(*keys, value: nil, &block)
      keys = convert_to_keys(keys)
      return unless deep_fetch(@settings, *keys).nil?

      block ? set(*keys, &block) : set(*keys, value: value)
    end

    # Bind a key to ENV variable
    #
    # @example
    #   set_from_env(:host)
    #   set_from_env(:foo, :bar) { 'HOST' }
    #
    # @param [Array<String>] keys
    #   the keys to bind to ENV variables
    #
    # @api public
    def set_from_env(*keys, &block)
      key = flatten_keys(keys)
      env_key = block.nil? ? key : block.()
      env_key = to_env_key(env_key)
      @envs[key.to_s.downcase] = env_key
    end

    # Convert config key to standard ENV var name
    #
    # @param [String] key
    #
    # @return [String]
    #
    # @api private
    def to_env_key(key)
      env_key = key.to_s.gsub(key_delim, env_separator).upcase
      if @env_prefix == ""
        env_key
      else
        "#{@env_prefix.to_s.upcase}#{env_separator}#{env_key}"
      end
    end

    # Fetch value under a composite key
    #
    # @example
    #   fetch(:foo, :bar, :baz)
    #
    # @example
    #   fetch("foo.bar.baz")
    #
    # @param [Array<String, Symbol>, String] keys
    #   the keys to get value at
    # @param [Object] default
    #   the default value
    #
    # @return [Object]
    #
    # @api public
    def fetch(*keys, default: nil, prefer: self.preferred, &block)
      # check alias
      real_key = @aliases[flatten_keys(keys)]
      keys = real_key.split(key_delim) if real_key

      keys = convert_to_keys(keys)
      env_key = autoload_env? ? to_env_key(keys[0]) : @envs[flatten_keys(keys)]

      case self.class.normalize_preferred(prefer)
      when :settings
        # first try settings
        value = deep_fetch(@settings, *keys)
        # then try ENV var
        if value.nil? && env_key
          value = ENV[env_key]
        end
        # then try default
        value = block || default if value.nil?
      when :environment
        # first try ENV var
        value = ENV[env_key] if env_key
        # then try settings
        if value.nil?
          value = deep_fetch(@settings, *keys)
        end
      else
        raise UnsupportedSource, "Preferred Source `#{prefer}` is not supported."
      end

      while callable_without_params?(value)
        value = value.()
      end
      value
    end

    # Merge in other configuration settings
    #
    # @param [Hash{Symbol => Object]] other_settings
    #
    # @return [Hash, nil]
    #   the combined settings or nil
    #
    # @api public
    def merge(other_settings)
      return unless other_settings.respond_to?(:to_hash)

      @settings = deep_merge(@settings, other_settings)
    end

    # Append values to an already existing nested key
    #
    # @example
    #   append(1, 2, to: %i[foo bar])
    #
    # @param [Array<Object>] values
    #   the values to append
    # @param [Array<String, Symbol] to
    #   the nested key to append to
    #
    # @return [Array<Object>]
    #   the values for a nested key
    #
    # @api public
    def append(*values, to: nil)
      keys = Array(to)
      set(*keys, value: Array(fetch(*keys)) + values)
    end

    # Remove a set of values from a nested key
    #
    # @example
    #   remove(1, 2, from: :foo)
    #
    # @example
    #   remove(1, 2, from: %i[foo bar])
    #
    # @param [Array<Object>] values
    #   the values to remove from a nested key
    # @param [Array<String, Symbol>, String] from
    #   the nested key to remove values from
    #
    # @api public
    def remove(*values, from: nil)
      keys = Array(from)
      raise ArgumentError, "Need to set key to remove from" if keys.empty?

      set(*keys, value: Array(fetch(*keys)) - values)
    end

    # Delete a value from a nested key
    #
    # @example
    #   delete(:foo, :bar, :baz)
    #
    # @example
    #   delete(:unknown) { |key| "#{key} isn't set" }
    #
    # @param [Array<String, Symbol>] keys
    #   the keys for a value deletion
    #
    # @yield [key] Invoke the block with a missing key
    #
    # @return [Object]
    #   the deleted value(s)
    #
    # @api public
    def delete(*keys, &default)
      keys = convert_to_keys(keys)
      deep_delete(*keys, @settings, &default)
    end

    # Define an alias to a nested key
    #
    # @example
    #   alias_setting(:foo, to: :bar)
    #
    # @param [Array<String>] keys
    #   the alias key
    #
    # @api public
    def alias_setting(*keys, to: nil)
      flat_setting = flatten_keys(keys)
      alias_keys = Array(to)
      alias_key = flatten_keys(alias_keys)

      if alias_key == flat_setting
        raise ArgumentError, "Alias matches setting key"
      end

      if fetch(alias_key)
        raise ArgumentError, "Setting already exists with an alias " \
                             "'#{alias_keys.map(&:inspect).join(', ')}'"
      end

      @aliases[alias_key] = flat_setting
    end

    # Register a validation rule for a nested key
    #
    # @param [Array<String>] keys
    #   a deep nested keys
    # @param [Proc] validator
    #   the logic to use to validate given nested key
    #
    # @api public
    def validate(*keys, &validator)
      key = flatten_keys(keys)
      values = validators[key] || []
      values << validator
      validators[key] = values
    end

    # Find configuration file matching filename and extension
    #
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
    def exist?
      !find_file.nil?
    end
    alias persisted? exist?

    # Find and read a configuration file.
    #
    # If the file doesn't exist or if there is an error loading it
    # the TTY::Config::ReadError will be raised.
    #
    # @param [String] file
    #   the path to the configuration file to be read
    #
    # @param [String] format
    #   the format to read configuration in
    #
    # @raise [TTY::Config::ReadError]
    #
    # @api public
    def read(file = find_file, format: :auto)
      if file.nil?
        raise ReadError, "No file found to read configuration from!"
      elsif !::File.exist?(file)
        raise ReadError, "Configuration file `#{file}` does not exist!"
      end

      set_file_metadata(file)

      ext = (format == :auto ? extname : ".#{format}")
      content = ::File.read(file)

      merge(unmarshal(content, ext: ext))
    end

    # Write current configuration to a file.
    #
    # @example
    #   write(force: true, create: true)
    #
    # @param [String] file
    #   the file to write to
    # @param [Boolean] create
    #   whether or not to create missing path directories, false by default
    # @param [Boolean] force
    #   whether or not to overwrite existing configuration file, false by default
    # @param [String] format
    #   the format name for the configuration file, :auto by defualt
    # @param [String] path
    #   the custom path to use to write a file to
    #
    # @raise [TTY::Config::WriteError]
    #
    # @api public
    def write(file = find_file, create: false, force: false, format: :auto,
              path: nil)
      file = fullpath(file, path)
      check_can_write(file, force)

      set_file_metadata(file)
      ext = (format == :auto ? extname : ".#{format}")
      content = marshal(@settings, ext: ext)
      filepath = Pathname.new(file)

      create_missing_dirs(filepath, create)
      ::File.write(filepath, content)
    end

    # Set file name and extension
    #
    # @example
    #   set_file_metadata("config.yml")
    #
    # @param [File] file
    #   the file to set metadata for
    #
    # @api public
    def set_file_metadata(file)
      self.extname  = ::File.extname(file)
      self.filename = ::File.basename(file, extname)
    end

    # Current configuration
    #
    # @api public
    def to_hash
      @settings.dup
    end
    alias to_h to_hash

    private

    # Ensure that value is set either through parameter or block
    #
    # @api private
    def assert_either_value_or_block(value, block)
      if value.nil? && block.nil?
        raise ArgumentError, "Need to set either value or block"
      elsif !(value.nil? || block.nil?)
        raise ArgumentError, "Can't set both value and block"
      end
    end

    # Check if object is a proc with no arguments
    #
    # @return [Boolean]
    #
    # @api private
    def callable_without_params?(object)
      object.respond_to?(:call) &&
        (!object.respond_to?(:arity) || object.arity.zero?)
    end

    # Wrap callback in a proc object that includes validation
    # that will be performed at point when a new proc is invoked.
    #
    # @param [String] key
    #   the key to set validation for
    # @param [Proc] callback
    #   the callback to wrap
    #
    # @return [Proc]
    #
    # @api private
    def delay_validation(key, callback)
      -> do
        val = callback.()
        assert_valid(key, val)
        val
      end
    end

    # Check if key passes all registered validations for a key
    #
    # @param [String] key
    #   the key to validate a value for
    # @param [Object] value
    #   the value to check
    #
    # @api private
    def assert_valid(key, value)
      validators[key].each do |validator|
        validator.(key, value)
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
    # @param [Array<Object>] keys
    #   the keys to nest
    #
    # @return [Hash]
    #   the nested setting
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

    # Convert key to an array of key elements
    #
    # @param [String, Array<String, Symbol>] keys
    #
    # @return [Array<String>]
    #
    # @api private
    def convert_to_keys(keys)
      first_key = keys[0]
      if first_key.to_s.include?(key_delim)
        first_key.split(key_delim)
      else
        keys.map(&:to_s)
      end
    end

    # Convert nested key from an array to a string
    #
    # @example
    #   flatten_keys(%i[foo bar baz]) # => "foo.bar.baz"
    #
    # @param [Array<String, Symbol>] keys
    #   the nested key to convert
    #
    # @return [String]
    #   the delimited nested key
    #
    # @api private
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
    #   the settings to search
    # @param [Array<Object>] keys
    #   the nested key to look up
    #
    # @return [Object, nil]
    #   the value or nil
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

    # Merge two deeply nested hash objects
    #
    # @param [Hash] this_hash
    # @param [Hash] other_hash
    #
    # @return [Hash]
    #   the merged hash object
    #
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

    # Delete a deeply nested key
    #
    # @param [Array<String>] keys
    #   the nested key to delete
    # @param [Hash{String => Object}]
    #   the settings to delete key from
    #
    # @return [Object]
    #   the deleted object(s)
    #
    # @api private
    def deep_delete(*keys, settings, &default)
      key, *rest = keys
      value = settings[key]
      if !rest.empty? && value.is_a?(::Hash)
        deep_delete(*rest, value, &default)
      elsif !value.nil?
        settings.delete(key)
      elsif default
        default.(key)
      end
    end

    # Search for a configuration file in a path
    #
    # @param [String] path
    #   the path to search
    #
    # @return [String, nil]
    #   the configuration file path or nil
    #
    # @api private
    def search_in_path(path)
      path = Pathname.new(path)
      extensions.each do |ext|
        if ::File.exist?(path.join("#{filename}#{ext}").to_s)
          return path.join("#{filename}#{ext}").to_s
        end
      end
      nil
    end

    # Create a full path to a configuration file
    #
    # @param [String] file
    #   the configuration file
    # @param [String] path
    #   the path to configuration file
    #
    # @return [String]
    #   the full path to a file
    #
    # @api private
    def fullpath(file, path)
      if file.nil?
        dir = path || @location_paths.first || Dir.pwd
        ::File.join(dir, "#{filename}#{@extname}")
      elsif file && path
        ::File.join(path, ::File.basename(file))
      else
        file
      end
    end

    # Check if a file can be written to
    #
    # @param [String] file
    #   the configuration file
    # @param [Boolean] force
    #   whether or not to force writing
    #
    # @raise [TTY::Config::WriteError]
    #
    # @return [nil]
    #
    # @api private
    def check_can_write(file, force)
      return unless file && ::File.exist?(file)

      if !force
        raise WriteError, "File `#{file}` already exists. " \
                          "Use :force option to overwrite."
      elsif !::File.writable?(file)
        raise WriteError, "Cannot write to #{file}."
      end
    end

    # Create any missing directories
    #
    # @param [Pathname] filepath
    #   the file path
    # @param [Boolean] create
    #   whether or not to create missing directories
    #
    # @raise [TTY::Config::WriteError]
    #
    # @return [nil]
    #
    # @api private
    def create_missing_dirs(filepath, create)
      if !filepath.dirname.exist? && !create
        raise WriteError, "Directory `#{filepath.dirname}` doesn't exist. " \
                          "Use :create option to create missing directories."
      else
        filepath.dirname.mkpath
      end
    end

    # Crate a marshaller instance based on the extension name
    #
    # @param [String] ext
    #   the extension name
    #
    # @return [nil, Marshaller]
    #
    # @api private
    def create_marshaller(ext)
      marshaller = marshallers.find { |marsh| marsh.ext.include?(ext) }

      return nil if marshaller.nil?

      marshaller.new
    end

    # Unmarshal content into a hash object
    #
    # @param [String] content
    #   the content to convert into a hash object
    #
    # @return [Hash{String => Object}]
    #
    # @api private
    def unmarshal(content, ext: nil)
      ext ||= extname
      if marshaller = create_marshaller(ext)
        marshaller.unmarshal(content)
      else
        raise ReadError, "Config file format `#{ext}` is not supported."
      end
    end

    # Marshal hash object into a configuration file content
    #
    # @param [Hash{String => Object}] object
    #   the object to convert to string
    #
    # @return [String]
    #
    # @api private
    def marshal(object, ext: nil)
      ext ||= extname
      if marshaller = create_marshaller(ext)
        marshaller.marshal(object)
      else
        raise WriteError, "Config file format `#{ext}` is not supported."
      end
    end
  end # Config
end # TTY
