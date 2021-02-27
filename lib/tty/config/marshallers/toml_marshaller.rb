# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      # Responsible for marshalling content from and into TOML format
      #
      # @api public
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
