# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class TOMLMarshaller < Abstract

        dependency "toml"

        extension ".toml"

        def marshal(data)
          TOML::Generator.new(data).body
        end

        def unmarshal(content)
          TOML::Parser.new(content).parsed
        end
      end # TOMLMarshaller
    end # Marshallers
  end # Config
end # TTY
