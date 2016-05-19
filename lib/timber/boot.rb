module Timber
  module Bootstrap
    def bootstrap!
      Probes.insert!
      LogDevice.install!
    end
  end
end
