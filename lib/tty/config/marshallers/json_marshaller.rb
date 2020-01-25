# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      class JSONMarshaller
        include TTY::Config::Marshaller

        dependency "json"

        extension ".json"

        def marshal(object)
          JSON.pretty_generate(object)
        end

        def unmarshal(content)
          JSON.parse(content)
        end
      end # JSONMarshaller
    end # Marshallers
  end # Config
end # TTY
