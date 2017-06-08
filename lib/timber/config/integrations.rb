require "timber/config/integrations/rack"
require "timber/integrations/action_controller"
require "timber/integrations/action_view"
require "timber/integrations/active_record"
require "timber/integrations/rack"

module Timber
  class Config
    # Convenience module for accessing the various `Timber::Integrations::*` classes
    # through the {Timber::Config} object. Timber couples configuration with the class
    # responsibls for implementing it. This provides for a tighter design, but also
    # requires the user to understand and access the various classes. This module aims
    # to provide a simple ruby-like configuration interface for internal Timber classes.
    #
    # For example:
    #
    #     config = Timber::Config.instance
    #     config.integrations.active_record.silence = true
    module Integrations
      extend self

      # Convenience method for accessing the {Timber::Integrations::ActionController} class
      # specific configuration.
      #
      # @example
      #   config = Timber::Config.instance
      #   config.integrations.action_controller.silence = true
      def action_controller
        Timber::Integrations::ActionController
      end

      # Convenience method for accessing the {Timber::Integrations::ActionView} class
      # specific configuration.
      #
      # @example
      #   config = Timber::Config.instance
      #   config.integrations.action_view.silence = true
      def action_view
        Timber::Integrations::ActionView
      end

      # Convenience method for accessing the {Timber::Integrations::ActiveRecord} class
      # specific configuration.
      #
      # @example
      #   config = Timber::Config.instance
      #   config.integrations.active_record.silence = true
      def active_record
        Timber::Integrations::ActiveRecord
      end

      # Convenience method for accessing the various `Timber::Integrations::Rack::*`
      # classes. See {Rack} for a list of methods available.
      #
      # @example
      #   config = Timber::Config.instance
      #   config.integrations.rack.http_events.enabled = true
      def rack
        Rack
      end
    end
  end
end