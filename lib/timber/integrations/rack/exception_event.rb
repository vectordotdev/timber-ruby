begin
  require "action_dispatch/middleware/exception_wrapper"
rescue Exception
end

require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # A Rack middleware that is reponsible for capturing exceptions events
      # {Timber::Events::Exception}.
      class ExceptionEvent < Middleware
        # We determine this when the app loads to avoid the overhead on a per request basis.
        EXCEPTION_WRAPPER_TAKES_CLEANER = if Gem.loaded_specs["rails"]
          Gem.loaded_specs["rails"].version >= Gem::Version.new('5.0.0')
        else
          false
        end

        def call(env)
          begin
            status, headers, body = @app.call(env)
          rescue Exception => exception
            Config.instance.logger.fatal do
              backtrace = extract_backtrace(env, exception)

              Events::Exception.new(
                name: exception.class.name,
                exception_message: exception.message,
                backtrace: backtrace
              )
            end

            raise exception
          end
        end

        private
          # Rails provides a backtrace cleaner, so we use it here.
          def extract_backtrace(env, exception)
            if defined?(::ActionDispatch::ExceptionWrapper)
              wrapper = if EXCEPTION_WRAPPER_TAKES_CLEANER
                request = Util::Request.new(env)
                backtrace_cleaner = request.get_header("action_dispatch.backtrace_cleaner")
                ::ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, exception)
              else
                ::ActionDispatch::ExceptionWrapper.new(env, exception)
              end

              trace = wrapper.application_trace
              trace = wrapper.framework_trace if trace.empty?
              trace
            else
              exception.backtrace
            end
          end
      end
    end
  end
end