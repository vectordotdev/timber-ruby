# Base
require "timber/probes/probe"

# Probes
require "timber/probes/action_controller"
require "timber/probes/heroku"

module Timber
  module Probes
    PROBES = [
      ActionController,
      Heroku
    ]

    def insert!
      probe.each(&:insert!)
    end
  end
end

Timber::Probes.insert!
