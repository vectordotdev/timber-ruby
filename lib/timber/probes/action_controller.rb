module Timber
  module Probes
    class ActionController < Probe
      module InstanceMethods
        def process_action(*args)
          context = Contexts::ActionController.new(self)
          CurrentContext.wrap(context) { super }
        end
      end

      def initialize
        require "actioncontroller"
      rescue LoadError => e
        raise RequirementUnsatisfiedError.new(e.message)
      end

      def insert!
        ::ActionController.send(:include, InstanceMethods)
      end
    end
  end
end
