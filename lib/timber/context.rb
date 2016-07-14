require "securerandom"

module Timber
  class Context
    include ClassLevelInheritableAttributes
    inheritable_attributes :properties
    self.properties ||= []

    class << self
      def property(*properties)
        @properties = properties
        attr_reader *properties
      end
    end

    SECURE_RANDOM_LENGTH = 32.freeze

    def _id
      @_id ||= generate_secure_random
    end

    def _version
      @_version ||= self.class.const_get(:VERSION)
    end

    def key_name
      @key_name ||= self.class.const_get(:KEY_NAME)
    end

    def as_json(*args)
      @as_json ||= {
        :_id => _id,
        :_version => _version
      }.tap do |h|
        properties.each do |property|
          # Don't include nil values, normalizes the results
          if !(value = send(property)).nil?
            h[property] = value
          end
        end
      end
    end

    def to_json(*args)
      # Note: this is run in the background thread, hence the hash creation.
      @to_json ||= as_json.to_json(*args)
    end

    private
      def generate_secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end

      def properties
        self.class.properties
      end
  end
end
