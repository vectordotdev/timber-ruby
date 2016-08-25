module Timber
  module LogDevices
    class IO < LogDevice
      class HybridFormatter < Formatter
        def initialize(options = {})
          super
          @date_prefix = options.key?(:date_prefix) ? options[:date_prefix] : false
        end

        def date_prefix?
          @date_prefix == true
        end

        def format(log_line)
          "#{log_line.message}#{context_message(log_line)}"
        end

        private
          def base_message(log_line)
            text = ""
            if date_prefix?
              text << "#{log_line.formatted_dt} "
            end
            text << log_line.message
            text
          end

          def context_message(log_line)
            # The callout must be before the formatting, otherwise we leave
            # the message ending with a color formatting and not a reset.
            # Anything before the callout modifies the original message.
            CALLOUT + ansi_format(DARK_GRAY, encoded_context(log_line))
          end

          def encoded_context(log_line)
            log_line.context_snapshot.to_logfmt
          end
      end
    end
  end
end