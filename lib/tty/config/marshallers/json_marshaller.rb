# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class JSONMarshaller < Abstract

        dependency "json"

        extension ".json"

        def marshal(data, options = {})
          JSON.pretty_generate(data)
        end

        def unmarshal(file, options = {})
          JSON.parse(::File.read(file))
        end
      end # JSONMarshaller
    end # Marshallers
  end # Config
end # TTY
