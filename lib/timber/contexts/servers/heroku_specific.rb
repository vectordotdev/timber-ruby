module Timber
  module Contexts
    module Servers
      # Because this is a sub context we do not extend Server.
      class HerokuSpecific < Context
        ROOT_KEY = :heroku.freeze
        VERSION = 1.freeze
        DELIMITER = ".".freeze

        class << self
          def json_shell(&_block)
            Server.json_shell { super }
          end
        end

        attr_reader :dyno

        def initialize(dyno)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @dyno = dyno
          super()
        end

        def process_type
          @process_type ||= parts.first
        end

        def dyno_id
          @dyno_id ||= parts.last
        end

        private
          def parts
            @parts ||= dyno.split(DELIMITER)
          end

          def json_payload
            @json_payload ||= Macros::DeepMerger.merge({
              # order is relevant for logfmt styling
              :process_type => process_type,
              :dyno_id => dyno_id
            }, super).freeze.freeze
          end
      end
    end
  end
end
