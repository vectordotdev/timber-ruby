module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      Probes.insert!
      LogDeviceInstaller.install!(logger)
      LogTruck.start
    end
  end
end
