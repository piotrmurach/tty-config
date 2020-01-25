# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      class TOMLMarshaller
        include TTY::Config::Marshaller

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
