require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # Custom contexts allow you to add application specific context not covered elsewhere.
    # Any data added this way will be included in your logs. A good example is worker job
    # IDs. When processing a job you might add the job ID to the context, allowing you to
    # view *all* logs generated while processing that job, not just the logs that contain
    # the ID.
    #
    # Note in the example below all custom contexts must contain a root key. This is to
    # ensure attribute names and types never clash across your contexts. It gives you
    # much cleaner pallete to organize your data on.
    #
    # @example Adding a custom context
    #   logger.with_context(build: {version: "1.0.0"}) do
    #     # anything logged here will have the custom context above
    #     # when this block exits the context will no longer be included
    #   end
    class Custom < Context
      @keyspace = :custom

      attr_reader :type, :data

      def initialize(attributes)
        @type = attributes[:type] || raise(ArgumentError.new(":type is required"))
        @data = attributes[:data] || raise(ArgumentError.new(":data is required"))
      end

      def as_json(_options = {})
        {Timber::Util::Object.try(type, :to_sym) => data}
      end
    end
  end
end