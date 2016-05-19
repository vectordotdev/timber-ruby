require "timber/probes/action_controller"
require "timber/probes/heroku"

module Timber
  module Probes
    PROBES = [
      ActionController,
      Heroku
    ]

    # Should be called to activate timber and insert probes
    def self.insert!
      PROBES.each(&:insert!)
    end
  end
end
