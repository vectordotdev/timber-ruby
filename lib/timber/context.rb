require "securerandom"

module Timber
  class Context
    include Patterns::ToJSON
    include Patterns::ToLogfmt

    SECURE_RANDOM_LENGTH = 16.freeze

    class << self
      def _version
        @_version ||= const_get(:VERSION)
      end

      def _path
        @_path ||= (const_defined?(:PATH) ? const_get(:PATH) : _root_key).to_s
      end

      def _root_key
        @_root_key ||= const_get(:ROOT_KEY)
      end
    end

    def _dt
      @_dt ||= Time.now.utc
    end

    def _version
      self.class._version
    end

    def _path
      self.class._path
    end

    def _root_key
      self.class._root_key
    end

    def as_json_with_index(index)
      keys = _path.split(".")
      hash = as_json
      target_hash = keys.inject(hash) do |acc, value|
        acc[value] || raise("could not find key #{inspect(value)}")
      end
      target_hash["_index"] = index
      hash
    end

    def inspect
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
          _root_key => {
            :_dt => Core::DateFormatter.format(_dt),
            :_version => _version
          }
        }
      end

      def generate_secure_random
        SecureRandom.urlsafe_base64(SECURE_RANDOM_LENGTH)
      end
  end
end
