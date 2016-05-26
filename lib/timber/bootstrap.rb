module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      if !Config.enabled?
        Config.logger.debug("Skipping Timber bootstrap, Timber::Config.enabled is not set to true")
        return false
      end

      if Config.application_id.nil?
        Config.logger.debug("Skipping Timber bootstrap, Timber::Config.application_id is not set")
        return false
      end

      if Config.application_key.nil?
        Config.logger.debug("Skipping Timber bootstrap, Timber::Config.application_key is not set")
        return false
      end

      Probes.insert!
      LogDeviceInstaller.install!(logger)
      LogTruck.start! if Config.log_truck_enabled?

      true
    end
  end
end
