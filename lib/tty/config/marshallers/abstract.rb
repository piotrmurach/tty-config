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

          # Set a list of extensions
          #
          # @example
          #   extenion "ext1", "ext2", "ext3"
          #
          # @api public
          def extension(*extensions)
            if extensions[0].is_a?(Array)
              @ext = extensions[0]
            else
              @ext = extensions
            end
          end
        end

        # Marshal object into a given format
        #
        # @param [Object] _object
        #
        # @api public
        def marshal(_object, _options = {})
          raise NotImplementedError
        end

        # Unmarshal content into a hash object
        #
        # @param [String] _content
        #
        # @api public
        def unmarshal(_content, _options = {})
          raise NotImplementedError
        end
      end
    end # Marshallers
  end # Config
end # TTY
