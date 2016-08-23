module Timber
  module LogDevices
    class IO < LogDevice
      class HybridFormatter < Formatter
        # Important that we do not change this, as the API matches on it
        # to perform it's special parsing. Spaces included.
        CONTEXT_DELIMITER = " [timber.io] ".freeze

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
            ansi_format(DARK_GRAY, "#{CONTEXT_DELIMITER}#{encoded_context(log_line)}")
          end

          def encoded_context(log_line)
            log_line.context_snapshot.to_logfmt
          end
      end
    end
  end
end