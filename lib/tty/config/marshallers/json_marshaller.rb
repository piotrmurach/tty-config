# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class JSONMarshaller < Abstract

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
