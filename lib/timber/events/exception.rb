module Timber
  module Events
    class Exception < Timber::Event
      attr_reader :name, :exception_message, :backtrace

      def initialize(attributes)
        @name = attributes[:name] || raise(ArgumentError.new(":name is required"))
        @exception_message = attributes[:exception_message] || raise(ArgumentError.new(":exception_message is required"))
        @backtrace = attributes[:backtrace]
      end

      def to_hash
        {name: name, message: exception_message, backtrace: backtrace}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:exception => to_hash}
      end

      def message
        message = "#{name} (#{exception_message}):"
        if backtrace.is_a?(Array) && backtrace.length > 0
          message << "\n\n"
          message << backtrace.join("\n")
        end
        message
      end
    end
  end
end