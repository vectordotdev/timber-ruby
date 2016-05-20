require "singleton"

module Timber
  module Patterns
    module DelegatedSingleton
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include Singleton
        end
      end

      module ClassMethods
        private
          def method_missing(name, *args, &block)
            instance.send(name, *args, &block)
          end
      end
    end
  end
end
