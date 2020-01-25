# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class YAMLMarshaller < Abstract

        dependency "yaml"

        extension ".yaml", ".yml"

        def marshal(object)
          YAML.dump(TTY::Config.normalize_hash(object, :to_s))
        end

        def unmarshal(content)
          if YAML.respond_to?(:safe_load)
            YAML.safe_load(content)
          else
            YAML.load(content)
          end
        end
      end # YAMLMarshaller
    end # Marshallers
  end # Config
end # TTY
