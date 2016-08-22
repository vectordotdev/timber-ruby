module Timber
  module LogDevices
    class IO < LogDevice
      class HybridHiddenFormatter < HybridFormatter
        CONTEXT_DELIMITER = "[timber.io]".freeze
        CLEAR_SEQUENCE = "\e8\e[K".freeze
        CLEAR_STEP_SIZE = 20.freeze
        SAVE_CURSOR_POSITION = "\e7".freeze

        def format(log_line)
          "#{SAVE_CURSOR_POSITION}#{context_message(log_line)}#{base_message(log_line)}"
        end

        private
          def context_message(log_line)
            text = "#{encoded_context(log_line)}#{CONTEXT_DELIMITER}"
            position = CLEAR_STEP_SIZE
            sequence_size = CLEAR_SEQUENCE.size
            while position < text.length
              text.insert(position, CLEAR_SEQUENCE)
              position += (sequence_size + CLEAR_STEP_SIZE)
            end
            text += CLEAR_SEQUENCE
            text
          end

          def encoded_context(log_line)
            log_line.context_snapshot.to_logfmt
          end
      end
    end
  end
end