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

    attr_reader :middleware, :insert_before

    def initialize(middleware, insert_before)
      @middleware = middleware
      @insert_before = insert_before
    end

    def bootstrap!
      unless can_bootstrap?
        log_cant_bootstrap_message
        return false
      end
      
      Probes.insert!(middleware, insert_before)

      if Config.log_truck_enabled?
        LogTruck.start!
      else
        Config.logger.warn("Log truck is disabled, enable with Config::Timber.log_truck_enabled = true")
      end
      
      log_started
      true
    end

    private
      def can_bootstrap?
        enabled? && has_application_key?
      end

      def log_cant_bootstrap_message
        unless enabled?
          Config.logger.warn("Can't bootstrap, Timber::Config.enabled must be true")
        end

        unless has_application_key?
          Config.logger.warn("Can't bootstrap, Timber::Config.application_key must be set")
        end          
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
