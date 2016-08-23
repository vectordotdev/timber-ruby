require "thread"

module Timber
  module LogDevices
    class HTTP < LogDevice
      # This is a thread safe queue for transporting logs to the Timber API.
      # TODO: Have these log lines persist to a file where
      #       a daemon can pick them up.
      class LogPile
        class << self
          def each(&block)
            instances.values.each(&block)
          end

          def get(application_key)
            instances[application_key] ||= new(application_key)
          end

          private
            def instances
              @instances ||= {}
            end
        end

        attr_reader :application_key

        def initialize(application_key)
          @application_key = application_key
          @mutex = Mutex.new
        end

        def drop(log_line)
          mutex.synchronize do
            log_lines << log_line
          end
        rescue LogLine::InvalidMessageError => e
          # Ignore the error and log it.
          Config.logger.error(e)
        rescue Exception => e
          # Fail safe to ensure the Timber gem never fails the app.
          Config.logger.exception(e)
        end

        def empty(&_block)
          if log_lines.any?
            copy = log_lines_copy
            yield(copy) if block_given?
            remove(copy)
            self
          end
        end

        def size
          log_lines.size
        end

        private
          def mutex
            @mutex
          end

          def remove(log_lines_copy)
            mutex.synchronize do
              # Delete items by object_id since we are working
              # with the same object. Do not use equality here.
              log_lines_copy.each do |l1|
                log_lines.delete_if { |l2| l2.object_id == l1.object_id }
              end
            end
          end

          def log_lines_copy
            mutex.synchronize do
              # Copy the array structure so we aren't dealing with
              # a changing array, but do not copy the items.
              log_lines.clone
            end
          end

          def log_lines
            @log_lines ||= []
          end
      end
    end
  end
end