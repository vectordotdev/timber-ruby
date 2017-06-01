require "timber/integrations/action_controller"
require "timber/integrations/action_dispatch"
require "timber/integrations/action_view"
require "timber/integrations/active_record"
require "timber/integrations/rack"
require "timber/integrations/rails"

module Timber
  # Namespace for all integrations. Each integration provides it's own settings.
  # And all integrations can be disabled with the {.enabled=} class method.
  module Integrations
    # Disable / enable _all_ integrations with one setting.
    def self.enabled=(value)
      ActionController.enabled = value
      ActionView.enabled = value
      ActiveRecord.enabled = value
      Rack.enabled = value
    end

    # Integrates all enabled integrations in one call.
    def self.integrate!
      ActionController.integrate!
      ActionDispatch.integrate!
      ActionView.integrate!
      ActiveRecord.integrate!
      Rails.integrate!
    end
  end
end