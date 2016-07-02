require "securerandom"

module Timber
  class Context
    class << self
      attr_reader :properties

      def property(*names)
        @properties = names
        attr_reader *names
      end
    end

    SECURE_RANDOM_LENGTH = 32.freeze

    attr_reader :id

    def initialize
      @id = generate_secure_random
    end

    def key_name
      self.class.const_get(:KEY_NAME)
    end

    def json
      @json ||= hash.to_json
    end

    def version
      self.class.const_get(:VERSION)
    end

    private
      def generate_secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end

      # Private so that we force callers to use #json. This is
      # better for performance. This way we aren't constantly converting
      # hashes to strings.
      def hash
        @hash ||= {
          :id => id,
          :version => version
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
