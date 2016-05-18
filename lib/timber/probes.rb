require "timber/probes/action_controller"
require "timber/probes/heroku"

module Timber
  module Probes
    PROBES = [
      ActionController,
      Heroku
    ]

    def self.insert!
      PROBES.each(&:insert!)
    end
  end
end

# Insert'em
Timber::Probes.insert!
