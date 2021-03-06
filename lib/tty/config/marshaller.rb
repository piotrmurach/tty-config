# frozen_string_literal: true

require_relative "dependency_loader"

module TTY
  class Config
    module Marshaller
      # @api private
      def self.included(base)
        super
        # Help marshallers to declare their gem dependency
        base.extend DependencyLoader
        # Help marshallers to declare their extension matching
        base.extend ExtensionsStore
      end

      module ExtensionsStore
        def ext
          @_ext ||= []
        end

        # Set a list of extensions
        #
        # @example
        #   extenion "ext1", "ext2", "ext3"
        #
        # @api public
        def extension(*extensions)
          if extensions[0].is_a?(Array)
            @_ext = extensions[0]
          else
            @_ext = extensions
          end
        end

        # Copy extensions to a subclass
        #
        # @param [Object] subclass
        #
        # @api private
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@_ext, @_ext.dup)
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
    end # Marshaller
  end # Config
end # TTY
