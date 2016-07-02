require "timber/probes/action_controller"
require "timber/probes/heroku"
require "timber/probes/logger"
require "timber/probes/rack"

module Timber
  module Probes
    def self.insert!(middleware)
      ActionController.insert!
      Heroku.insert!
      Logger.insert!
      Rack.insert!(middleware)
    end
  end
end
