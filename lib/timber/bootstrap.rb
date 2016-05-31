module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      if !Config.enabled?
        Config.logger.warn("Skipping Timber bootstrap, Timber::Config.enabled is not set to true")
        return false
      end

      if Config.application_key.nil?
        Config.logger.warn("Skipping Timber bootstrap, Timber::Config.application_key is not set")
        return false
      end

      Probes.insert!
      LogDeviceInstaller.install!(logger)
      LogTruck.start! if Config.log_truck_enabled?
      log_message = <<-LOG
_,-,
T_  | Timber enabled
||`-'
||
||
~~
LOG
      Config.logger.info(log_message.strip)

      true
    end
  end
end
