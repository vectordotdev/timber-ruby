module Timber
  module LogDevices
    class IO < LogDevice
      class HybridHiddenFormatter < HybridFormatter
        CLEAR_SEQUENCE = "\e8\e[K".freeze
        CLEAR_STEP_SIZE = 20.freeze
        SAVE_CURSOR_POSITION = "\e7".freeze

        def format(log_line)
          "#{SAVE_CURSOR_POSITION}#{context_message(log_line)}#{base_message(log_line)}"
        end

        private
          def context_message(log_line)
            text = encoded_context(log_line)
            position = CLEAR_STEP_SIZE
            sequence_size = CLEAR_SEQUENCE.size
            step_size = sequence_size + CLEAR_STEP_SIZE
            while position < text.length
              # ensure we don't insert before a \
              while text[position - 1] == "\\"
                position += 1
              end
              text.insert(position, CLEAR_SEQUENCE)
              position += step_size
            end
            ansi_format(DARK_GRAY, "#{CALLOUT}#{CLEAR_SEQUENCE}#{text} #{CALLOUT_END}#{CLEAR_SEQUENCE}")
          end

          def encoded_context(log_line)
            log_line.context_snapshot.to_logfmt
          end
      end
    end
  end
end