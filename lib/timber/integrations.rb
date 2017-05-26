require "timber/integrations/action_controller"
require "timber/integrations/action_dispatch"
require "timber/integrations/action_view"
require "timber/integrations/active_record"
require "timber/integrations/rack"
require "timber/integrations/rails"

module Timber
  # Namespace for all integrations.
  # @private
  module Integrations
    #
    def self.enabled=(value)
      @enabled = value
    end

    # Accessor method for {#enabled=}.
    def self.enabled?
      @enabled != false
    end

    # Integrates all enabled integrations in one call.
    def self.integrate!
      return true if !enabled?

      ActionController.integrate!
      ActionDispatch.integrate!
      ActionView.integrate!
      ActiveRecord.integrate!
      Rails.integrate!
    end
  end
end