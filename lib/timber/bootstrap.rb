module Timber
  module Bootstrap
    def self.bootstrap!(logger)
      tag = Logger::TAG

      if !Config.enabled?
        logger.warn("#{tag} Skipping bootstrap, Timber::Config.enabled is not true")
        return false
      end

      if Config.application_key.nil?
        # TODO: Add a better explanation on how to get a key. Perhaps a rake task
        #       That provides a quick setup.
        logger.warn("#{tag} Skipping bootstrap, Timber::Config.application_key is nil")
        return false
      end

      Probes.insert!
      LogDeviceInstaller.install!(logger)
      LogTruck.start! if Config.log_truck_enabled?
      log_message = <<-LOG
#{tag}  _,-,
       T_  | Timber enabled
       ||`-'
       ||
       ||
       ~~
LOG
      log_message.strip!
      log_message.split("\n").each do |line|
        logger.info(line)
      end

      true
    end
  end
end
