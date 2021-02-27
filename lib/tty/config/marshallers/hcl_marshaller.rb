# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      # Responsible for marshalling content from and into HCL format
      #
      # @api public
      class HCLMarshaller
        include TTY::Config::Marshaller

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
