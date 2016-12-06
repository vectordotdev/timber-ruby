module Timber
  module Probes
    class RailsRackLogger < Probe # :nodoc:
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            protected
              def started_request_message(request)
                Events::HTTPRequest.new(
                  host: request.host,
                  method: request.request_method,
                  path: request.filtered_path,
                  port: request.port,
                  query_params: request.GET,
                  content_type: request.content_type,
                  remote_addr: request.ip,
                  referrer: request.referer,
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