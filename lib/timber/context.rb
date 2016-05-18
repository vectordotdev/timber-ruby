require "securerandom"

module Timber
  class Context
    SECURE_RANDOM_LENGTH = 32

    attr_reader :id

    def initialize
      @id = generate_secure_random
    end

    def to_hash
      {
        :id => id,
        :version => version
      }
    end

    def to_json(*args)
      to_hash.to_json(*args)
    end

    def version
      self.class.const_get(:VERSION)
    end

    private
      def secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end
  end
end
