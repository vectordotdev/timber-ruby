require "timber/context"

module Timber
  module Contexts
    # The runtime context adds current runtime data to your logs, such as the file, line number,
    # class or module name, etc. This makes it easy to tail and search your logs by their
    # origin in your code. For example, if you are debugging a specific class, you can narrow
    # by that class and see only it's logs.
    class Runtime < Context
      APPLICATION_MAX_BYTES = 256.freeze
      CLASS_NAME_MAX_BYTES = 256.freeze
      FILE_MAX_BYTES = 1024.freeze
      FUNCTION_MAX_BYTES = 256.freeze
      MODULE_NAME_MAX_BYTES = 256.freeze
      VM_PID_MAX_BYTES = 256.freeze

      @keyspace = :runtime

      attr_reader :application, :class_name, :file, :function, :line, :module_name, :vm_pid

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @application = normalizer.fetch(:application, :string, :limit => APPLICATION_MAX_BYTES)
        @class_name = normalizer.fetch(:class_name, :string, :limit => CLASS_NAME_MAX_BYTES)
        @file = normalizer.fetch(:file, :string, :limit => FILE_MAX_BYTES)
        @function = normalizer.fetch(:function, :string, :limit => FUNCTION_MAX_BYTES)
        @line = normalizer.fetch(:line, :integer)
        @module_name = normalizer.fetch(:module_name, :string, :limit => MODULE_NAME_MAX_BYTES)
        @vm_pid = normalizer.fetch(:vm_pid, :string, :limit => VM_PID_MAX_BYTES)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:application, application)
          h.add(:class_name, class_name)
          h.add(:file, file)
          h.add(:function, function)
          h.add(:line, line)
          h.add(:module_name, module_name)
          h.add(:vm_pid, vm_pid)
        end
      end
    end
  end
end
