# frozen_string_literal: true

require_relative "abstract"

module TTY
  class Config
    module Marshallers
      class HCLMarshaller < Abstract

        dependency "rhcl"

        extension ".hcl"

        def marshal(data, options = {})
          Rhcl.dump(data)
        end

        def unmarshal(file, options = {})
          Rhcl.parse(::File.read(file))
        end
      end # HCLMarshaller
    end # Marshallers
  end # Config
end # TTY
