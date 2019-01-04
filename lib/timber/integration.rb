module Timber
  # An integration represent an integration for an entire library. For example, `Rack`.
  # While the Timber `Rack` integration is comprised of multiple middlewares, the
  # `Timber::Integrations::Rack` module is an entire integration that extends this module.
  module Integration
    # Easily sisable entire library integrations. This is like removing the code from
    # Timber. It will not touch this library and the library will function as it would
    # without Timber.
    #
    # @example
    #   Timber::Integrations::ActiveRecord.enabled = false
    def enabled=(value)
      @enabled = value
    end

    # Accessor method for {#enabled=}
    def enabled?
      @enabled != false
    end

    # Silences a library's logs. This ensures that logs are not generated at all
    # from this library.
    #
    # @example
    #   Timber::Integrations::ActiveRecord.silence = true
    def silence=(value)
      @silence = value
    end

    # Accessor method for {#silence=}
    def silence?
      @silence == true
    end

    # Abstract method that each integration must implement.
    def integrate!
      raise NotImplementedError.new
    end
  end
end
