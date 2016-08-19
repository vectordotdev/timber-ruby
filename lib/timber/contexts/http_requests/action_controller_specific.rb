module Timber
  module Contexts
    module HTTPRequests
      # Extend Context since we are a sub context and not an actual HTTPRequest
      class ActionControllerSpecific < Context
        PATH = "#{Rack._root_key}.action_controller"
        ROOT_KEY = :action_controller.freeze
        VERSION = 1.freeze

        attr_reader :controller_obj

        def initialize(controller_obj)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @controller_obj = controller_obj
          super()
        end

        def action
          @action ||= controller_obj.action_name
        end

        def controller
          @controller ||= controller_obj.class.name
        end

        def format
          @format ||= controller_obj.request.format.try(:ref)
        end

        private
          def json_payload
            @json_payload ||= DeepMerger.merge(super, {
              Rack._root_key => {
                _root_key => {
                  :action => action,
                  :controller => controller,
                  :format => format
                }
              }
            })
          end
      end
    end
  end
end
