# frozen_string_literal: true

require 'pathname'

require_relative 'config/version'

module TTY
  class Config
    # Error raised when key fails validation
    LoadError = Class.new(StandardError)

    def self.coerce(hash, &block)
      new(normalize_hash(hash), &block)
    end

    # Convert string keys to symbols
    #
    # @api private
    def self.normalize_hash(hash)
      hash.reduce({}) do |acc, (key, val)|
        acc[key.to_sym] = val.is_a?(::Hash) ? normalize_hash(val) : val
        acc
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

    def initialize(settings = {})
      @location_paths = []
      @settings = settings
      @validators = {}
      @filename = 'config'
      @ext_type = '.yml'
      @extensions = ['.yaml', '.yml']
      @key_delim = '.'

      yield(self) if block_given?
    end

    def append_path(path)
      @location_paths << path
    end

    def prepend_path(path)
      @location_paths.unshift(path)
    end

    # Set a value for a composite key and overrides any existing keys.
    # Keys are case-insensitive
    #
    # @api public
    def set(*keys, value: nil, &block)
      assert_either_value_or_block(value, block)
      keys = convert_to_keys(keys)

      deepest_setting = deep_set(@settings, *keys[0...-1])
      deepest_setting[keys.last] = block || value
      deepest_setting[keys.last]
    end

    # Set a value for a composite key if not present already
    #
    # @param [Array[String|Symbol]] keys
    #   the keys to set value for
    #
    # @api public
    def set_if_empty(*keys, value: nil, &block)
      return unless deep_find(@settings, keys.last).nil?
      block ? set(*keys, &block) : set(*keys, value: value)
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
      value = deep_fetch(@settings, *keys)
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

    # Find and read a configuration file.
    #
    # If the file doesn't exist or if there is an error loading it
    # the TTY::Config::LoadError will be raised.
    #
    # @param [String] file
    #   the path to the configuration file to be read
    #
    # @raise [TTY::Config::LoadError]
    #
    # @api public
    def read(file = find_file)
      if file.nil?
        raise LoadError, "No file found to read configuration from!"
      elsif !::File.exist?(file)
        raise LoadError, "Configuration file `#{file}` does not exist!"
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
      if file && !force
        raise "File `#{file}` alraedy exists."
      elsif file && !::File.writable?(file)
        raise "Cannot write to #{file}."
      elsif file
        marshal(file, @settings)
      else
        marshal("#{filename}#{@ext_type}", @settings)
      end
    end

    # Current configuration
    #
    # @api public
    def to_hash
      @settings.dup
    end

    private

    def callable_without_params?(object)
      object.respond_to?(:call) &&
        (!object.respond_to?(:arity) || object.arity.zero?)
    end

    def assert_either_value_or_block(value, block)
      return if value.nil? || block.nil?
      raise ArgumentError, "Can't set both value and block"
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
      first_key.to_s.include?(key_delim) ? first_key.split(key_delim) : keys
    end

    # Fetch value under deeply nested keys
    #
    # @param [Hash] settings
    #
    # @param [Array[Object]] keys
    #
    # @api private
    def deep_fetch(settings, *keys)
      key, *rest = keys
      value = settings[key]
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
    def find_file
      @location_paths.each do |location_path|
        path = search_in_path(location_path)
        return path if path
      end
      nil
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
      ext = File.extname(file)
      case ext
      when '.yaml', '.yml'
        require 'yaml'

        if YAML.respond_to?(:safe_load)
          YAML.safe_load(File.read(file))
        else
          YAML.load(File.read(file))
        end
      else
        raise "Config file format `#{ext}` not supported."
      end
    end

    # @api private
    def marshal(file, data)
      ext = ::File.extname(file)
      case ext
      when '.yaml', '.yml'
        require 'yaml'
        File.write(file, YAML.dump(data))
      else
        raise "Config file format `#{ext}` not supported."
      end
    end
  end
end
