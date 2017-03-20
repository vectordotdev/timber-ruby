module Timber
  module Probes
    # Responsible for automatically tracking the http request events for Rails applications.
    #
    # Note, we modify the existing class because it is coupled with ActiveSupport instrumentation
    # for some reason.
    # See: https://github.com/rails/rails/blob/80e66cc4d90bf8c15d1a5f6e3152e90147f00772/railties/lib/rails/rack/logger.rb#L34
    class RailsRackLogger < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            protected
              if klass.private_instance_methods.include?(:started_request_message) || klass.method_defined?(:started_request_message)
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
                Events::HTTPServerRequest.new(
                  content_type: request.content_type,
                  host: request.host,
                  method: request.request_method,
                  path: request.filtered_path,
                  port: request.port,
                  query_string: request.query_string,
                  remote_addr: request.remote_ip, # we insert this middleware after ActionDispatch::RemoteIp
                  referrer: referrer,
                  request_id: request.request_id, # we insert this middleware after ActionDispatch::RequestId
                  scheme: request.scheme,
                  user_agent: request.user_agent
                )
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