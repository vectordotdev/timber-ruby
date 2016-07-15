require "timber/probes/action_controller"
require "timber/probes/action_dispatch_debug_exceptions"
require "timber/probes/action_view"
require "timber/probes/active_record"
require "timber/probes/heroku"
require "timber/probes/logger"
require "timber/probes/rack"

module Timber
  module Probes
    def self.insert!(middleware, insert_before)
      ActionController.insert!
      ActionView.insert!
      ActiveRecord.insert!
      Heroku.insert!
      Logger.insert!
      Rack.insert!(middleware, insert_before)
    end
  end
end
