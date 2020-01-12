# frozen_string_literal: true

require_relative "marshaller_registry"

module TTY
  class Config
    module Marshallers
      NO_EXT = ""

      def marshaller_registry
        @marshaller_registry ||= MarshallerRegistry.new
      end

      def marshallers
        marshaller_registry.objects
      end

      def extensions
        marshaller_registry.exts << NO_EXT
      end

      def registered?(name_or_object)
        marshaller_registry.registered?(name_or_object)
      end

      def register(name, object)
        marshaller_registry.register(name, object)
      end

      def unregister(*names)
        names.map { |name| marshaller_registry.unregister(name) }
      end
    end # Marshallers
  end # Config
end # TTY
