module Timber
  class Config
    module Integrations
      # Convenience module for accessing the various `Timber::Integrations::Rack::*` classes
      # through the {Timber::Config} object. Timber couples configuration with the class
      # responsibls for implementing it. This provides for a tighter design, but also
      # requires the user to understand and access the various classes. This module aims
      # to provide a simple ruby-like configuration interface for internal Timber classes.
      #
      # For example:
      #
      #     config = Timber::Config.instance
      #     config.integrations.rack.http_events.enabled = false
      module Rack
        extend self

        # Convenience method for accessing the {Timber::Integrations::Rack::ErrorEvent}
        # middleware class specific configuration. See {Timber::Integrations::Rack::ExceptionEvent}
        # for a list of methods available.
        #
        # @example
        #   config = Timber::Config.instance
        #   config.integrations.rack.error_event.enabled = false
        def error_event
          Timber::Integrations::Rack::ErrorEvent
        end

        # Convenience method for accessing the {Timber::Integrations::Rack::HTTPContext}
        # middleware class specific configuration. See {Timber::Integrations::Rack::HTTPContext}
        # for a list of methods available.
        #
        # @example
        #   config = Timber::Config.instance
        #   config.integrations.rack.http_context.enabled = false
        def http_context
          Timber::Integrations::Rack::HTTPContext
        end

        # Convenience method for accessing the {Timber::Integrations::Rack::HTTPEvents}
        # middleware class specific configuration. See {Timber::Integrations::Rack::HTTPEvents}
        # for a list of methods available.
        #
        # @example
        #   config = Timber::Config.instance
        #   config.integrations.rack.http_events.enabled = false
        def http_events
          Timber::Integrations::Rack::HTTPEvents
        end

        # Convenience method for accessing the {Timber::Integrations::Rack::SessionContext}
        # middleware class specific configuration. See {Timber::Integrations::Rack::SessionContext}
        # for a list of methods available.
        #
        # @example
        #   config = Timber::Config.instance
        #   config.integrations.rack.session_context.enabled = false
        def session_context
          Timber::Integrations::Rack::SessionContext
        end

        # Convenience method for accessing the {Timber::Integrations::Rack::UserContext}
        # middleware class specific configuration. See {Timber::Integrations::Rack::UserContext}
        # for a list of methods available.
        #
        # @example
        #   config = Timber::Config.instance
        #   config.integrations.rack.user_context.enabled = false
        def user_context
          Timber::Integrations::Rack::UserContext
        end
      end
    end
  end
end