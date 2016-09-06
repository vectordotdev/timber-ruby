require File.join(File.dirname(__FILE__), "http", "log_pile")
require File.join(File.dirname(__FILE__), "http", "log_truck")

module Timber
  module LogDevices
    class HTTP < LogDevice
      SPLIT_LINES = false

      attr_reader :application_key

      def initialize(application_key = nil)
        @application_key = application_key || Config.application_key
        if @application_key.nil?
          raise ArgumentError.new("A Timber application_key is required")
        end
        LogTruck.start!
      end

      def close(*args)
      end

      private
        def write_log_line(log_line)
          LogPile.get(application_key).drop(log_line)
        end
    end
  end
end