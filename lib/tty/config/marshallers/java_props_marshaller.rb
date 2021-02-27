# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      # Responsible for marshalling content from and into Java properties format
      #
      # @api public
      class JavaPropsMarshaller
        include TTY::Config::Marshaller

        dependency "java-properties"

        extension ".properties", ".props", ".prop"

        def marshal(object)
          JavaProperties.generate(object)
        end

        def unmarshal(content)
          JavaProperties.parse(content)
        end
      end # JavapropsMarshaller
    end # Marshallers
  end # Config
end # TTY
