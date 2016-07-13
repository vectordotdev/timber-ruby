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

    def to_json
      @json ||= to_hash.to_json
    end

    private
      def generate_secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end

      # Private so that we force callers to use #json. This is
      # better for performance. This way we aren't constantly converting
      # hashes to strings.
      def to_hash
        @hash ||= {
          :_id => _id,
          :_version => _version
        }.tap do |h|
          properties.each do |property|
            h[property] = send(property)
          end
        end
      end

      def properties
        self.class.properties
      end
  end
end
