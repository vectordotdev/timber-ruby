require "uri"
require "net/http"
require "net/https"

module Timber
  # Temporary class for alpha / beta purposes.
  # Log lines will be written to a file where a daemon
  # will pick them up.
  class LogTruck
    THROTTLE_SECONDS = 3.freeze
    READ_TIMEOUT = 15.freeze
    TARGET = URI.parse("https://timber-odin.herokuapp.com/")
    HTTPS = Net::HTTP.new(TARGET.host, TARGET.port).tap do |https|
      https.use_ssl = true
      https.read_timeout = READ_TIMEOUT # seconds
    end
    CONTENT_TYPE = 'application/json'.freeze

    # Error classes
    class NoPayloadError < ArgumentError; end
    class DeliveryError < StandardError; end

    class << self
      def start(options = {}, &block)
        # Old school options to support ruby 1.9 :(
        options[:throttle_seconds] = THROTTLE_SECONDS if !options.key?(:throttle_seconds)

        # A new thread for looping and monitoring. We need to
        # use a thread so that we can share memory.
        Thread.new do
          loop do
            begin
              deliver!
            rescue DeliveryError => e
              # Note: if this fails it will try again
              # TODO: handle subsequent failures by increasing the backoff rate
              Config.logger.error(e)
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
        LogPile.empty do |log_line_hashes|
          # LogPile only empties if no exception is raised
          log_truck = new(log_line_hashes).tap(&:deliver!)
        end
        log_truck
      end
    end

    attr_reader :log_line_hashes

    def initialize(log_line_hashes)
      if log_line_hashes.empty?
        raise NoPayloadError.new("a truck must contain at least one log line")
      end
      @log_line_hashes = log_line_hashes
    end

    def deliver!
      HTTPS.request(new_request).tap do |res|
        if res.code.to_s != "200"
          raise DeliveryError.new("Bad response from Timber API - #{res.code}: #{res.body}")
        end
      end
    rescue Exception => e
      # Ensure that we are always returning a consistent error.
      # This ensures we handle it appropriately and don't kill the
      # thread above.
      raise DeliveryError.new(e.to_s)
    end

    private
      def new_request
        Net::HTTP::Post.new(TARGET).tap do |req|
          req['Content-Type'] = CONTENT_TYPE
          req.body = log_line_hashes.to_json
        end
      end
  end
end
