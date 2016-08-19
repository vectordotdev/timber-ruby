module Timber
  module Contexts
    module Servers
      # Because this is a sub context we do not extend Server.
      class HerokuSpecific < Context
        PATH = "#{Server._root_key}.heroku"
        ROOT_KEY = :heroku.freeze
        VERSION = 1.freeze
        DELIMITER = ".".freeze

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
            @json_payload ||= DeepMerger.merge(super, {
              Server._root_key => {
                _root_key => {
                  :dyno_id => dyno_id,
                  :process_type => process_type
                }
              }
            })
          end
      end
    end
  end
end
