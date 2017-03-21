module Timber
  module Integrations
    module Rack
      # Reponsible for capturing exceptions events within a Rack stack.
      class ExceptionEvent
        def initialize(app)
          @app = app
        end

        def call(env)
          begin
            status, headers, body = @app.call(env)
          rescue Exception => exception
            Config.instance.logger.fatal do
              Events::Exception.new(
                name: exception.class.name,
                exception_message: exception.message,
                backtrace: exception.backtrace
              )
            end

            raise exception

            status ||= extract_status(exception.class)

            [status, headers, body]
          end
        end

        private
          def extract_status(exception_class_name)
            if defined?(::ActionDispatch::ExceptionWrapper)
              ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
            elsif defined?(::ActionDispatch::ShowExceptions)
              # Rails 3.X
              ::Rack::Utils.status_code(::ActionDispatch::ShowExceptions.rescue_responses[exception_class_name])
            else
              500
            end
          end
      end
    end
  end
end