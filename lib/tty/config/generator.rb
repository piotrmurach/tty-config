# frozen_string_literal: true

module TTY
  class Config
    module Generator
      # Generate file content based on the data hash
      #
      # @param [Hash] data
      #
      # @return [String]
      #   the file content
      #
      # @api public
      def self.generate(data, separator: '=')
        content  = []
        values   = {}
        sections = {}

        data.keys.sort.each do |key|
          val = data[key]
          if val.is_a?(NilClass)
            next
          elsif val.is_a?(Hash) ||
                (val.is_a?(Array) && val.first.is_a?(Hash))
            sections[key] = val
          elsif val.is_a?(Array)
            values[key] = val.join(',')
          else
            values[key] = val
          end
        end

        # values
        values.each do |key, val|
          content << "#{key} #{separator} #{val}"
        end
        content << '' unless values.empty?

        # sections
        sections.each do |section, object|
          next if object.empty? # only add section if values present

          content << "[#{section}]"
          if object.is_a?(Array)
            object = object.reduce({}, :merge!)
          end
          object.each do |key, val|
            val = val.join(',') if val.is_a?(Array)
            content << "#{key} #{separator} #{val}" if val
          end
          content << ''
        end
        content.join("\n")
      end
    end # INIFile
  end # Config
end # TTY
