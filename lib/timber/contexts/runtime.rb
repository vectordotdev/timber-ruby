require "timber/context"

module Timber
  module Contexts
    # The runtime context adds current runtime data to your logs, such as the file, line number,
    # class or module name, etc. This makes it easy to tail and search your logs by their
    # origin in your code. For example, if you are debugging a specific class, you can narrow
    # by that class and see only it's logs.
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

      # Builds a hash representation of containing simply objects, suitable for serialization.
      def as_json(_options = {})
        {application: application, class_name: class_name, file: file, function: function,
          line: line, module_name: module_name}
      end
    end
  end
end