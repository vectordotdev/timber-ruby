module Timber
  module LogDevices
    # @private
    #
    # A log device that writes to multiple IO devices.
    #
    # Note, you should not have to instantiate this class directly. Simply pass multiple
    # arguments to the `Timber::Logger#new` method.
    #
    # See the {Timber::Logger#new} for examples.
    class Multi
      def initialize(targets)
        @targets = targets
      end

      def write(*args)
        @targets.each { |t| t.write(*args) }
        @targets.first
      end

      def sync=(value)
        @targets.each do |t|
          if t.respond_to?(:sync=)
            t.sync = value
          end
        end
      end

      def close
        @targets.each(&:close)
      end
    end
  end
end