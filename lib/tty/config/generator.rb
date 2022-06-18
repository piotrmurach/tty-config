# frozen_string_literal: true

module TTY
  class Config
    # Responsible for converting a data object into content in INI format
    #
    # @api private
    module Generator
      # Generate file content based on the data hash
      #
      # @example
      #   generate({"foo" => {"bar" => "baz"}})
      #   # => "[foo]\nbar = baz\n"
      #
      # @param [Hash{String => Object}] data
      #   the data to convert to INI file format
      # @param [String] separator
      #   the separator for the key and value pairs
      #
      # @return [String]
      #   the INI file content
      #
      # @api public
      def self.generate(data, separator: "=")
        sections_and_values = group_into_sections_and_values(data)

        values = generate_values(sections_and_values[:values], separator)
        values << "" unless values.empty?
        sections = generate_sections(sections_and_values[:sections], separator)

        content = values + sections
        content.join("\n")
      end

      # Group data into sections and values
      #
      # @param [Hash{String => Object}] data
      #   the data to group
      #
      # @return [Hash{Symbol => Hash}]
      #   the sections and values
      #
      # @api private
      def self.group_into_sections_and_values(data)
        sections_and_values = {sections: {}, values: {}}
        data.sort.each_with_object(sections_and_values) do |(key, val), group|
          group[section?(val) ? :sections : :values][key] = val
        end
      end
      private_class_method :group_into_sections_and_values

      # Check whether or not a value is a section
      #
      # @param [Object] value
      #   the value to check
      #
      # @return [Boolean]
      #   return true if value is a section, false otherwise
      #
      # @api private
      def self.section?(value)
        value.is_a?(Hash) ||
          (value.is_a?(Array) && value.all? { |val| val.is_a?(Hash) })
      end
      private_class_method :section?

      # Generate key and value pairs
      #
      # @param [Hash{String => Object}] values
      #   the values to convert to INI format
      # @param [String] separator
      #   the separator for the key and value pairs
      #
      # @return [Array<String>]
      #   the formatted key and value pairs
      #
      # @api private
      def self.generate_values(values, separator)
        values.each_with_object([]) do |(key, val), content|
          next if val.nil?

          content << generate_pair(key, val, separator)
        end
      end
      private_class_method :generate_values

      # Generate key and value pair
      #
      # @param [String] key
      #   the key to convert to INI format
      # @param [Object] value
      #   the value to convert to INI format
      # @param [String] separator
      #   the separator for the key and value pair
      #
      # @return [String]
      #   the formatted key and value pair
      #
      # @api private
      def self.generate_pair(key, value, separator)
        value = value.join(",") if value.is_a?(Array)
        "#{key} #{separator} #{value}"
      end
      private_class_method :generate_pair

      # Generate sections with key and value pairs
      #
      # @param [Hash{String => Object}] sections
      #   the sections to convert to INI format
      # @param [String] separator
      #   the separator for the key and value pairs
      #
      # @return [Array<String>]
      #   the formatted sections with key and value pairs
      #
      # @api private
      def self.generate_sections(sections, separator)
        sections.each_with_object([]) do |(section, object), content|
          next if object.empty? # skip section with no values

          content << "[#{section}]"
          object = object.reduce({}, :merge) if object.is_a?(Array)
          content.concat(generate_values(object, separator))
          content << ""
        end
      end
      private_class_method :generate_sections
    end # Generator
  end # Config
end # TTY
