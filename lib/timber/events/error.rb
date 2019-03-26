require "timber/util"
require "timber/event"

module Timber
  module Events
    # @private
    class Error < Timber::Event
      attr_reader :name, :error_message, :backtrace_json

      def initialize(attributes)
        @name = attributes[:name]
        @error_message = attributes[:error_message]

        if attributes[:backtrace]
          @backtrace_json = attributes[:backtrace].to_json
        end
      end

      def message
        message = "#{name}"

        if !error_message.nil?
          message << " (#{error_message})"
        end

        message
      end

      def to_hash
        {
          error: {
            name: name,
            message: error_message,
            backtrace_json: backtrace_json
          }
        }
      end
    end
  end
end
