require "logger"

module Timber
  module Probes
    class Logger < Probe
      module InstanceMethods
        def add(level, *args, &block)
          context = Contexts::Logger.new(level, progname)
          CurrentContext.add(context) do
            super
          end
        end
      end

      def insert!
        return true if ::Logger.include?(InstanceMethods)
        ::Logger.send(:include, InstanceMethods)
      end
    end
  end
end
