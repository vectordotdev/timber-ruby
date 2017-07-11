module Timber
  module Integrations
    module ActiveJob
      class JobContext < Integrator
        module AddJobContext
          def self.included(klass)
            klass.class_eval do
              around_perform do |job, block, _|
                context = Contexts::Job.new(id: job.job_id)
                CurrentContext.with(context) do
                  block.call
                end
              end
            end
          end
        end

        def initialize
          require "active_job"
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end

        def integrate!
          if defined?(::ActiveJob::Base) && !::ActiveJob::Base.include?(AddJobContext)
            ::ActiveJob::Base.send(:include, AddJobContext)
          end
        end
      end
    end
  end
end