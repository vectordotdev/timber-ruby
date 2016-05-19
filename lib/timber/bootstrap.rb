module Timber
  module Bootstrap
    def bootstrap!(logger)
      Probes.insert!
      LogDeviceInstaller.install!(logger)
    end
  end
end
