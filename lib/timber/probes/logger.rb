require "logger"

module Timber
  module Probes
    class Logger < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            alias_method :_timber_old_add, :add

            def add(level, *args, &block)
              if self == Config.logger
                _timber_old_add(level, *args, &block)
              else
                context = Contexts::Logger.new(level, progname)
                Config.logger.warn("Adding logger for #{level} #{args.inspect}")
                CurrentContext.add(context) do
                  _timber_old_add(level, *args, &block)
                end
              end
            end
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
