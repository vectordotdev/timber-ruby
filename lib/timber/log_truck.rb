require "uri"
require "net/http"
require "net/https"
require "timber/log_truck/delivery"

module Timber
  # Temporary class for alpha / beta purposes.
  # Log lines will be written to a file where a daemon
  # will pick them up. Most of this code will be moved
  # to that daemon.
  class LogTruck
    THROTTLE_SECONDS = 3.freeze

    class NoPayloadError < ArgumentError; end

    class << self
      def start!(options = {}, &block)
        # Old school options to support ruby 1.9 :(
        options[:throttle_seconds] = THROTTLE_SECONDS if !options.key?(:throttle_seconds)
        Config.logger.debug("Started log truck with a #{options[:throttle_seconds]} second throttle")

        # A new thread for looping and monitoring. We need to
        # use a thread so that we can share memory.
        Thread.new do
          loop do
            begin
              deliver!
            rescue Delivery::DeliveryError => e
              # Note: if this fails it will try again
              # TODO: Kill the thread after a certain number of failed retires :/
              # TODO: How do we handle server timeouts? The request could have still been processed.
            end

            # Yield a block, primarily for testing purposes
            yield(Thread.current) if block_given?

            # Throttle to reduce checking the pile
            sleep options[:throttle_seconds]
          end
        end
      end

      # Deliver, return LogTruck object, otherwise
      # raise an error.
      def deliver!
        log_truck = nil
        LogPile.empty do |log_line_jsons|
          # LogPile only empties if no exception is raised
          log_truck = new(log_line_jsons).tap(&:deliver!)
        end
        log_truck
      end
    end

    attr_reader :log_line_jsons

    def initialize(log_line_jsons)
      if log_line_jsons.empty?
        raise NoPayloadError.new("a truck must contain a payload (at least one log line)")
      end
      @log_line_jsons = log_line_jsons
    end

    def deliver!
      Delivery.new(log_line_jsons).deliver!
    end
  end
end
