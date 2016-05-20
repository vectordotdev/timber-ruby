require "timber/probes/action_controller"
require "timber/probes/heroku"
require "timber/probes/logger"

module Timber
  module Probes
    PROBES = [
      ActionController,
      Heroku,
      Logger
    ]

    # Should be called to activate timber and insert probes
    def self.insert!
      PROBES.each(&:insert!)
    end
  end
end
