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
    def self.integrate!
      ActionController.integrate! if ActionController.enabled?
      ActionDispatch.integrate! if ActionDispatch.enabled?
      ActionView.integrate! if ActionView.enabled?
      ActiveRecord.integrate! if ActiveRecord.enabled?
      Rails.integrate! if Rails.enabled?
    end
  end
end