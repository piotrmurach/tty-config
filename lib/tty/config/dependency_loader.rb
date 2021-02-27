# frozen_string_literal: true

module TTY
  class Config
    module DependencyLoader
      attr_reader :dep_name

      # Lazy load a dependency
      #
      # @api public
      def dependency(*dep_names, &block)
        self.dep_name = dep_names
        @block = block
      end

      # Load dependency before object instatiation
      #
      # @api public
      def new(*)
        load
        super
      end

      # Try loading depedency
      #
      # @api private
      def load
        return if dep_name.nil?

        dep_name.empty? ? @block.() : dep_name.each { |dep| require(dep) }
      rescue LoadError, NameError => err
        raise DependencyLoadError, "#{raise_error_message} #{err.message}"
      end

      def inherited(subclass)
        super
        subclass.send(:dep_name=, dep_name)
      end

      private

      def raise_error_message
        if dep_name.empty?
          "One or more dependency are missing."
        elsif dep_name.size == 1
          "The dependency `#{dep_name.join}` is missing."
        else
          "The dependencies `#{dep_name.join(', ')}` are missing."
        end
      end

      attr_writer :dep_name
    end # DependencyLoader
  end # Config
end # TTY
