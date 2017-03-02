module Timber
  module Events
    # The exception event is used to track exceptions.
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionDispatchDebugExceptions} probe.
    class Exception < Timber::Event
      attr_reader :name, :exception_message, :backtrace

      def initialize(attributes)
        @name = attributes[:name] || raise(ArgumentError.new(":name is required"))
        @exception_message = attributes[:exception_message] || raise(ArgumentError.new(":exception_message is required"))

        backtrace = attributes[:backtrace]
        if backtrace.nil? || backtrace == []
          raise(ArgumentError.new(":backtrace is required"))
        end

        @backtrace = backtrace.collect { |line| parse_backtrace_line(line) }
      end

      def to_hash
        {name: name, message: exception_message, backtrace: backtrace}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:server_side_app => {:exception => to_hash}}
      end

      def message
        "#{name} (#{exception_message})"
      end

      private
        def parse_backtrace_line(line)
          # using split for performance reasons
          file, line, function_part = line.split(":", 3)
          _prefix, function = function_part.split("`", 2)
          {file: file, line: line.to_i, function: function.chomp("'")}
        end
    end
  end
end