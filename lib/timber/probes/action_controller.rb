module Timber
  module Probes
    class ActionController < Probe
      module InstanceMethods
        def process_action(*args)
          context = Contexts::ActionController.new(self)
          CurrentContext.add(context) do
            super
          end
        end
      end

      def initialize
        require "action_controller"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        ::ActionController::Base.send(:include, InstanceMethods)
      end
    end
  end
end
