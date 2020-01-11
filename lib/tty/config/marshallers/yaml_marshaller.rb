# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class YAMLMarshaller < Abstract

        dependency "yaml"

        def marshal(data, options = {})
          YAML.dump(TTY::Config.normalize_hash(data, :to_s))
        end

        def unmarshal(file, options = {})
          if YAML.respond_to?(:safe_load)
            YAML.safe_load(::File.read(file))
          else
            YAML.load(::File.read(file))
          end
        end
      end # YAMLMarshaller
    end # Marshallers
  end # Config
end # TTY
