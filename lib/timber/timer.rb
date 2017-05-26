module Timber
  # This is an ultra-simple abstraction for timing code. This provides a little
  # more control around how Timber automatically processes "timers".
  module Timer
    def start
      Time.now
    end
  end
end