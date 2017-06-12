require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The job context tracks job or task execution.
    #
    # @note This is tracked automatically in {Integrations::ActiveJob}. If you are not using
    #   `ActiveJob` you can easily add this yourself. See example.
    #
    # @example Track jobs / tasks manually
    #   # See note above, this might be tracked automatically.
    #   job_context = Timber::Contexts::Job.new(id: "my_job_id")
    #   logger.with_context(job_context) do
    #     # anything logged here will have the job context included.
    #   end
    class Job < Context
      @keyspace = :job

      attr_reader :id

      def initialize(attributes)
        @id = attributes[:id]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {id: Timber::Util::Object.try(id, :to_s)}
      end
    end
  end
end