# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      # Responsible for marshalling content from and into YAML format
      #
      # @api public
      class YAMLMarshaller
        include TTY::Config::Marshaller

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
