require "timber/contexts/rack_request/params"

module Timber
  module Contexts
    class ActionControllerResponse < HTTPResponse
      attr_reader :controller
      attr_accessor :event

      def initialize(controller)
        @controller = controller
      end

      def content_length
        @content_length ||= response.content_length
      end

      def cache_control
        @cache_control ||= response.headers['Cache-Control']
      end

      def content_disposition
        @content_disposition ||= response.headers['Cache-Disposition']
      end

      def content_type
        @content_type ||= response.headers['Content-Type']
      end

      def location
        @location ||= response.headers['Location']
      end

      def status
        @status ||= response.status
      end

      def time_ms
        @time_ms ||= event.duration
      end

      def valid?
        !response.nil? && !event.nil?
      end

      private
        def response
          controller.response
        end
    end
  end
end