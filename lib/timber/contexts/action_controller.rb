module Timber
  module Contexts
    class ActionController < Context
      VERSION = "1"

      attr_reader :controller,
        :action,
        :params,
        :format,
        :method,
        :path,
        :request_id

      def initialize(controller)
        super()
        request = controller.request
        @controller = controller.class.name
        @action = controller.action_name
        @params = request.filtered_parameters
        @format = request.format.try(:ref)
        @method = request.request_method
        @path = (request.fullpath rescue "unknown")
        @request_id = request.request_id rescue nil
      end

      def to_hash
        super.merge(
          :controller => controller,
          :action => action,
          :params => params,
          :format => format,
          :method => method,
          :path => path,
          :request_id => request_id
        )
      end
    end
  end
end
