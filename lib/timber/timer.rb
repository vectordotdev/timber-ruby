module Timber
  # This is an ultra-simple abstraction for timing code. This provides a little
  # more control around how Timber automatically processes "timers".
  #
  # @example
  #   timer = Timber::Timer.start
  #   # ... code to time
  #   logger.info("My log message", my_event: {time_ms: timer})
  module Timer
    # Abstract for starting a timber. Currently this is simply calling `Time.now`.
    def self.start
      Time.now
    end

    # Get the duration in milliseconds from the object returned in {#start}
    def self.duration_ms(timer)
      now = Time.now
      (now - timer) * 1000.0
    end
  end
end