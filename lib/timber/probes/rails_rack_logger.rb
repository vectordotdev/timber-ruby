module Timber
  module Probes
    # Responsible for automatically tracking the http request events for applications
    # that use `Rack`.
    class RailsRackLogger < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            protected
              if klass.method_defined?(:started_request_message)
                def started_request_message(request)
                  http_request_event(request)
                end
              elsif klass.method_defined?(:before_dispatch)
                def before_dispatch(env)
                  request = ActionDispatch::Request.new(env)
                  info do
                    http_request_event(request)
                  end
                end
              end

              def http_request_event(request)
                # No idea why rails 3.X returns a "/" :/
                referrer = request.referer == "/" ? nil : request.referer
                Events::HTTPRequest.new(
                  host: request.host,
                  method: request.request_method,
                  path: request.filtered_path,
                  port: request.port,
                  query_params: request.GET,
                  content_type: request.content_type,
                  remote_addr: request.ip,
                  referrer: referrer,
                  request_id: request_id(request.env),
                  user_agent: request.user_agent
                )
              end

              def request_id(env)
                env["X-Request-ID"] ||
                  env["X-Request-Id"] ||
                  env["action_dispatch.request_id"]
              end
          end
        end
      end

      module BeforeDispatchInstanceMethods
        def self.included(klass)
          klass.class_eval do
            protected
              def before_dispatch(env)
                request = ActionDispatch::Request.new(env)
                path = request.filtered_path

                info "\n\nStarted #{request.request_method} \"#{path}\" " \
                     "for #{request.ip} at #{Time.now.to_default_s}"
              end
          end
        end
      end

      def initialize
        require "rails/rack/logger"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ::Rails::Rack::Logger.include?(InstanceMethods)
        ::Rails::Rack::Logger.send(:include, InstanceMethods)
      end
    end
  end
end