module Timber
  module LogDevices
    class HerokuLogplex < IO
      class Line < IO::Line
        private
          def base_message
            # remove dt since that is included by default in the logplex format
            @base_message ||= log_line.message
          end

          def encoded_context
            @encoded_context ||= log_line.context_snapshot.to_logfmt(
              :except => [Contexts::Servers::HerokuSpecific]
            )
          end
      end

      def initialize
        super(STDOUT)
      end

      private
        def line_class
          Line
        end
    end
  end
end