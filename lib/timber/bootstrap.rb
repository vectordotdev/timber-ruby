module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      if !Config.enabled?
        Config.logger.warn("Skipping bootstrap, Timber::Config.enabled is not true")
        return false
      end

      if Config.application_key.nil?
        Config.logger.warn("Skipping bootstrap, Timber::Config.application_key is nil")
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
      log_message.split("\n").each do |line|
        Config.logger.info(line)
      end

      true
    end
  end
end
