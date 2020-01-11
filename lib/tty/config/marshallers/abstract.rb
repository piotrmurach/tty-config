# frozen_string_literal: true

require_relative "../dependency_loader"

module TTY
  class Config
    module Marshallers
      class Abstract
        # Help marshallers to declare their gem dependency
        extend DependencyLoader

        # Marshal data a given format
        def marshal(_data, _options = {})
          raise NotImplementedError
        end

        # Unmarshal from a file
        # @api public
        def unmarshal(_file, _options = {})
          raise NotImplementedError
        end
      end
    end # Marshallers
  end # Config
end # TTY
