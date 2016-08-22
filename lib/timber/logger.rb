require "logger"

module Timber
  # A simple interface to instantiate a logger. It does a couple of things:
  # 1. Simplifies Rails logger instantiation across Rails versions. This
  #    helps with simplifying the Readme / install instructions.
  # 2. Serves as a placeholder should we want to extend the logger and add
  #    Timber specific functionality.
  module Logger
    def self.new(logger_or_logdev = nil)
      logger = if logger_or_logdev.is_a?(::Logger)
        logger_or_logdev
      else
        Frameworks.logger(logger_or_logdev)
      end
      logger.extend(self)
      logger
    end
  end
end