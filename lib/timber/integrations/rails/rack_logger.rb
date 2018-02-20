require "timber/integrator"

module Timber
  module Integrations
    module Rails
      # Disables the default rail's rack logging. Note, we cannot simply uninstall this rack
      # middleware because rails couples this with ActiveSupport instrumentation. As such,
      # we simply disable the logger and let our Rack middleware handle the logging.
      #
      # See: https://github.com/rails/rails/blob/80e66cc4d90bf8c15d1a5f6e3152e90147f00772/railties/lib/rails/rack/logger.rb#L34
      #
      # @private
      class RackLogger < Integrator

        # @private
        module InstanceMethods
          LOGGER = ::Logger.new(nil)

          # We remove the request ID since Timber captures the request context automatically.
          # This is preferrably to tags since it is proper structured data. Moreover,
          # the Timber interface defaults to prepending log lines with the request_id.
          TAGS_TO_EXCLUDE = [:request_id]

          def self.included(klass)
            klass.class_eval do
              def initialize(app, taggers = nil)
                @app = app
                if taggers
                  @taggers = taggers.reject { |t| TAGS_TO_EXCLUDE.include?(t) } || []
                else
                  @taggers = []
                end
              end

              private
                if ::Rails::VERSION::MAJOR == 3
                  # Rails 3.2 calls Rails.logger directly in call_app, so we
                  # will just replace it with a version that doesn't
                  def call_app(_, env)
                    # Put some space between requests in development logs.
                    if ::Rails.env.development?
                      ::Rails.logger.info ''
                      ::Rails.logger.info ''
                    end
                    @app.call(env)
                  ensure
                    ActiveSupport::LogSubscriber.flush_all!
                  end
                end

                # Rails > 3.2 uses a logger method. Muting logs is accomplished by
                # passing a dummy logger instance with a nil log device.
                def logger
                  LOGGER
                end
            end
          end
        end

        def initialize
          require "rails/rack/logger"
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end

        def integrate!
          return true if ::Rails::Rack::Logger.include?(InstanceMethods)

          ::Rails::Rack::Logger.send(:include, InstanceMethods)
        end
      end
    end
  end
end