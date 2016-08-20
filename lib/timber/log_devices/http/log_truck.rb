require "uri"
require "net/http"
require "net/https"
require File.join(File.dirname(__FILE__), "log_truck", "delivery")

module Timber
  module LogDevices
    class HTTP < LogDevice
      # Temporary class for alpha / beta purposes.
      # Log lines will be written to a file where a daemon
      # will pick them up. Most of this code will be moved
      # to that daemon.
      class LogTruck
        THROTTLE_SECONDS = 3.freeze

        class NoPayloadError < ArgumentError; end

        class << self
          def start!(options = {}, &block)
            return if @thread && @thread.alive?

            # Old school options to support ruby 1.9 :(
            options[:throttle_seconds] = THROTTLE_SECONDS if !options.key?(:throttle_seconds)
            Config.logger.debug("Starting log truck with a #{options[:throttle_seconds]} second throttle")

            # A new thread for looping and monitoring. We need to
            # use a thread so that we can share memory.
            @thread = Thread.new do
              # ensure we always deliver upon exiting
              at_exit { deliver }

              # Keep looking for logs
              loop do
                deliver

                # Yield a block, primarily for testing purposes
                yield(Thread.current) if block_given?

                # Throttle to reduce checking the pile
                sleep options[:throttle_seconds]
              end
            end

          rescue Exception => e
            # failsafe to ensure we don't kill the app
            Config.logger.exception(e)
          end

          # Deliver, return LogTruck object, otherwise
          # raise an error.
          def deliver
            log_truck = nil
            LogPile.each do |log_pile|
              log_pile.empty do |log_lines|
                # LogPile only empties if no exception is raised
                begin
                  # This will retry a number of times. If we can't get it during the retries
                  # we drop the logs. Note, this strategy will improve when we write to a file
                  # and use an actual agent.
                  log_truck = new(log_pile.application_key, log_lines).tap(&:deliver!)
                rescue Delivery::DeliveryError => e
                  Config.logger.exception(e)
                  # TODO: How do we handle server timeouts? The request could have still been processed.
                end
              end
            end
            log_truck
          end
        end

        attr_reader :application_key, :log_lines

        def initialize(application_key, log_lines)
          if log_lines.empty?
            raise NoPayloadError.new("a truck must contain a payload (at least one log line)")
          end
          @application_key = application_key
          @log_lines = log_lines
        end

        def deliver!
          Delivery.new(application_key, log_lines).deliver!
        end
      end
    end
  end
end
