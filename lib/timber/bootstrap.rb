module Timber
  # Intermediary class between frameworks and Timber. Normalizes
  # the setup process.
  class Bootstrap
    def self.bootstrap!(logger, middleware)
      new(logger, middleware).bootstrap!
    end

    attr_reader :logger, :middleware

    def initialize(logger, middleware)
      if logger.nil?
        raise ArgumentError.new("logger is required")
      end

      @logger = logger
      @middleware = middleware
    end

    def bootstrap!
      return false unless can_bootstrap?

      # TODO: this overrides any custom loggers set in config. We
      #       want to honor any custom logger they set, but default to the
      #       rails logger if they dont.
      Config.logger = logger
      Probes.insert!(middleware)
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
          logger.warn("#{log_tag} Skipping bootstrap, Timber::Config.enabled is not true")
          false
        else
          true
        end
      end

      def has_application_key?
        if Config.application_key.nil?
          # TODO: Add a better explanation on how to get a key. Perhaps a rake task
          #       That provides a quick setup.
          logger.warn("#{log_tag} Skipping bootstrap, Timber::Config.application_key is nil")
          false
        else
          true
        end
      end

      def log_tag
        Logger::TAG
      end

      def log_message
        return @log_message if defined?(@log_message)
        @log_message = <<-LOG
#{log_tag}  _,-,
#{log_tag} T_  | Timber enabled
#{log_tag} ||`-'
#{log_tag} ||
#{log_tag} ||
#{log_tag} ~~
LOG
        @log_message.strip!
        @log_message
      end

      def log_started
        log_message.split("\n").each do |line|
          logger.info(line)
        end
      end
  end
end
