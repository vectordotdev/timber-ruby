module Timber
  module Overrides
    module LoggerAdd
      def self.included(klass)
        klass.class_eval do
          alias_method :_timber_original_add, :add

          def add(severity, message = nil, progname = nil)
            # Extract the message: https://github.com/ruby/ruby/blob/f6e77b9d3555c1fbaa8aab1cdc0bd6bde95f62c6/lib/logger.rb#L461-L468
            progname ||= @progname
            if message.nil?
              if block_given?
                message = yield
              else
                message = progname
                progname = @progname
              end
            end

            if message.is_a?(::Timber::Event)
              if self.is_a?(::Timber::Logger)
                _timber_original_add(severity, message, progname)
              else
                _timber_original_add(severity, message.message, progname)
              end
            else
              _timber_original_add(severity, message, progname)
            end
          end
        end
      end
    end
  end
end

require "logger"

::Logger.send(:include, Timber::Overrides::LoggerAdd)