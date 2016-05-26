module Timber
  module Bootstrap
    def bootstrap!(logger)
      Probes.insert!
      LogDeviceInstaller.install!(logger)
      LogTruck.start
    end
  end
end
