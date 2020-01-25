# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class HCLMarshaller < Abstract

        dependency "rhcl"

        extension ".hcl"

        def marshal(object)
          Rhcl.dump(object)
        end

        def unmarshal(content)
          Rhcl.parse(content)
        end
      end # HCLMarshaller
    end # Marshallers
  end # Config
end # TTY
