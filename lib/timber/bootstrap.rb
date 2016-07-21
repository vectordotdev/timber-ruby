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
      return false unless enabled?
      
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
      def enabled?
        if !Config.enabled?
          Config.logger.warn("Skipping bootstrap, Timber::Config.enabled is not true")
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
