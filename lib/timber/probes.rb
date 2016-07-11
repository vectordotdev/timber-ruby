require "timber/probes/action_controller"
require "timber/probes/active_record"
require "timber/probes/heroku"
require "timber/probes/logger"
require "timber/probes/rack"

module Timber
  module Probes
    def self.insert!(middleware, insert_before)
      ActionController.insert!
      ActiveRecord.insert!
      Heroku.insert!
      Logger.insert!
      Rack.insert!(middleware, insert_before)
    end
  end
end
