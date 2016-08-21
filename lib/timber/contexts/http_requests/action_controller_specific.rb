module Timber
  module Contexts
    module HTTPRequests
      # Extend Context since we are a sub context and not an actual HTTPRequest
      class ActionControllerSpecific < Context
        ROOT_KEY = :action_controller.freeze
        VERSION = 1.freeze

        class << self
          def json_shell(&block)
            Rack.json_shell { super }
          end
        end

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
            @json_payload ||= Macros::DeepMerger.merge({
              # order is relevant for logfmt styling
              :controller => controller,
              :action => action,
              :format => format
            }, super)
          end
      end
    end
  end
end
