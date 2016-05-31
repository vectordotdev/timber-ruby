module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      if !Config.enabled?
        logger.warn("Skipping Timber bootstrap, Timber::Config.enabled is not true")
        return false
      end

      if Config.application_key.nil?
        logger.warn("Skipping Timber bootstrap, Timber::Config.application_key is nil")
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
      log_message.strip!
      log_message = " " + log_message
      logger.info(log_message)

      true
    end
  end
end
