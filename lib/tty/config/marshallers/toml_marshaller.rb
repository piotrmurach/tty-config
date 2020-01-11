# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class TOMLMarshaller < Abstract

        dependency "toml"

        def marshal(data, options = {})
          TOML::Generator.new(data).body
        end

        def unmarshal(file, options = {})
          TOML.load(::File.read(file))
        end
      end # TOMLMarshaller
    end # Marshallers
  end # Config
end # TTY
