module Timber
  # Intermediary class between frameworks and Timber. Defines
  # requirements and normalized the setup process.
  class Bootstrap
    def self.bootstrap!(*args)
      new(*args).bootstrap!
    rescue Exception => e
      # Failsafe to ensure Timber never takes down the app
      Config.logger.exception(e)
    end

    attr_reader :logger, :middleware, :insert_before

    def initialize(logger, middleware, insert_before)
      @logger = logger
      @middleware = middleware
      @insert_before = insert_before
    end

    def bootstrap!
      return false unless can_bootstrap?

      # TODO: this overrides any custom loggers set in config. We
      #       want to honor any custom logger they set, but default to the
      #       rails logger if they dont.
      Config.logger = logger
      Probes.insert!(middleware, insert_before)
      LogDeviceInstaller.install!(logger)
      LogTruck.start! if Config.log_truck_enabled?
      log_started
      true
    end

    private
      def can_bootstrap?
        enabled? && has_application_key?
      end

      def enabled?
        if !Config.enabled?
          Config.logger.warn("Skipping bootstrap, Timber::Config.enabled is not true")
          false
        else
          true
        end
      end

      def has_application_key?
        if Config.application_key.nil?
          # TODO: Add a better explanation on how to get a key. Perhaps a rake task
          #       That provides a quick setup.
          Config.logger.warn("Skipping bootstrap, Timber::Config.application_key is nil")
          false
        else
          true
        end
      end

      def log_started
        Config.logger.info(" _,-,")
        Config.logger.info("T_  | Timber enabled")
        Config.logger.info("||`-'")
        Config.logger.info("||")
        Config.logger.info("||")
        Config.logger.info("~~")
      end
  end
end
