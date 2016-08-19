module Timber
  module Contexts
    module HTTPResponses
      class ActionController < HTTPResponse
        class Headers
          include Patterns::ToJSON

          attr_reader :response

          def initialize(response)
            @response = response
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

          private
            def json_payload
              @json_payload ||= {
                :content_length => content_length,
                :cache_control => cache_control,
                :content_disposition => content_disposition,
                :content_type => content_type,
                :location => location
              }
            end
        end

        attr_reader :controller
        attr_accessor :event

        def initialize(controller)
          @controller = controller
        end

        def headers
          @headers ||= Headers.new(response)
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
end