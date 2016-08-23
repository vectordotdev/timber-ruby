require "securerandom"

module Timber
  class Context
    include Patterns::ToJSON
    include Patterns::ToLogfmt

    PATH_DELIMITER = ".".freeze
    SECURE_RANDOM_LENGTH = 16.freeze

    class << self
      def json_shell(&_block)
        {_root_key => yield}
      end

      def _path
        @path ||= Macros::LogfmtEncoder.encode(json_shell { 1 }).split("=").first
      end

      def _root_key
        @_root_key ||= const_get(:ROOT_KEY)
      end

      def _version
        @_version ||= const_get(:VERSION)
      end
    end

    def _dt
      @_dt ||= Time.now.utc
    end

    def _path
      self.class._path
    end

    def _version
      self.class._version
    end

    def _root_key
      self.class._root_key
    end

    def as_json(*args)
      @as_json ||= json_shell { super }
    end

    def json_shell(&block)
      self.class.json_shell(&block)
    end

    def inspect(*args)
      "#<#{self.class.name}:#{object_id} ...>"
    end

    # Some contexts hold mutable object that change as the context block
    # executes. This method checks the state of that object to ensure
    # that the context is valid and ready to be copied for each log line.
    def valid?
      true
    end

    private
      def json_payload
        @json_payload ||= {
          :_dt => Macros::DateFormatter.format(_dt),
          :_version => _version
        }
      end

      def generate_secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end
  end
end
