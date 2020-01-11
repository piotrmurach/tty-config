# frozen_string_literal: true

require_relative "../dependency_loader"

module TTY
  class Config
    module Marshallers
      class Abstract
        # Help marshallers to declare their gem dependency
        extend DependencyLoader

        class << self
          def ext
            @ext ||= []
          end

          def extension(*extensions)
            if extensions[0].is_a?(Array)
              @ext = extensions[0]
            else
              @ext = extensions
            end
          end
        end

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
