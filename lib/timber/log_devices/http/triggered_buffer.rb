require "monitor"

module Timber
  module LogDevices
    class HTTP
      # Maintains a triggered buffer, where the trigger is {PAYLOAD_LIMIT_BYTES}. Once the buffer
      # exceeds this limit it will lock and return that buffer up to that point while still making
      # a new buffer available for writes. This ensures that the HTTP client can attempt to deliver
      # the buffer contents without blocking execution of the application.
      #
      # If the overall buffer exceeeds the overall limit (specified by the `:limit_bytes` option),
      # then a buffer overflow is triggered. This can be customized using the `:overflow_handler`
      # option.
      class TriggeredBuffer
        DEFAULT_PAYLOAD_LIMIT_BYTES = 5_000_000 # 5mb, the Timber API will not accept messages larger than this
        DEFAULT_LIMIT_BYTES = 50_000_000 # 50mb

        def initialize(options = {})
          @buffers = []
          @monitor = Monitor.new
          @payload_limit_bytes = options[:payload_limit_bytes] || DEFAULT_PAYLOAD_LIMIT_BYTES
          @limit_bytes = options[:limit_bytes] || DEFAULT_LIMIT_BYTES
          @overflow_handler = options[:overflow_handler]
        end

        def write(msg)
          if msg.bytesize > @payload_limit_bytes || (msg.bytesize + total_bytesize) > @limit_bytes
            handle_overflow(msg)
            return nil
          end

          @monitor.synchronize do
            buffer = writable_buffer
            if @buffers == [] || buffer.nil? || buffer.frozen?
              @buffers << msg
              nil
            elsif (buffer.bytesize + msg.bytesize) > @payload_limit_bytes
              @buffers << msg
              buffer.freeze
            else
              buffer << msg
              nil
            end
          end
        end

        def reserve
          @monitor.synchronize do
            buffer = writable_buffer
            if buffer
              buffer.freeze
            end
          end
        end

        def remove(buffer)
          @monitor.synchronize do
            @buffers.delete(buffer)
          end
        end

        private
          def total_bytesize
            @buffers.reduce(0) { |acc, buffer| acc + buffer.bytesize }
          end

          def writable_buffer
            @buffers.find { |buffer| !buffer.frozen? }
          end

          def handle_overflow(msg)
            if @overflow_handler
              @overflow_handler.call(msg)
            end
          end
      end
    end
  end
end