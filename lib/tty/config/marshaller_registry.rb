# frozen_string_literal: true

module TTY
  class Config
    class MarshallerRegistry

      attr_reader :marshallers

      # @api private
      def initialize(mappings = {})
        @marshallers = mappings
      end

      def names
        marshallers.keys
      end

      def objects
        marshallers.values
      end

      def exts
        marshallers.values.reduce([]) { |acc, obj| acc + obj.ext }
      end

      def registered?(name_or_object)
        marshallers.key?(name_or_object) || marshallers.has_value?(name_or_object)
      end

      def register(name, object)
        marshallers[name] = object
      end

      def unregister(name)
        marshallers.delete(name)
      end

      def [](name)
        marshallers.fetch(name)
      end
    end
  end # Config
end # TTY
