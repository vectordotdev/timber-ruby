module Timber
  module Contexts
    # Tracks OS level process information, such as the process ID.
    class Runtime < Context
      @keyspace = :runtime

      attr_reader :application, :class_name, :file, :function, :line, :module_name

      def initialize(attributes)
        @application = attributes[:application]
        @class_name = attributes[:class_name]
        @file = attributes[:file]
        @function = attributes[:function]
        @line = attributes[:line]
        @module_name = attributes[:module_name]
      end

      def as_json(_options = {})
        {application: application, class_name: class_name, file: file, function: function,
          line: line, module_name: module_name}
      end
    end
  end
end