require "timber/contexts/rack_request/params"

module Timber
  module Contexts
    class ActionControllerResponse < HTTPResponse
    	attr_accessor :event

    	def initialize(event)
    		@event = event
    	end

    	def content_length
    		@content_length ||= payload[:content_length]
    	end

    	def cache_control
    		@cache_control ||= payload[:cache_control]
    	end

    	def content_disposition
    		@content_disposition ||= payload[:content_disposition]
    	end

    	def content_type
    		@content_type ||= payload[:content_type]
    	end

    	def location
    		@location ||= payload[:location]
    	end

    	def status
    		@status ||= payload[:status]
    	end

    	def time_ms
    		@time_ms ||= event.duration
    	end

    	private
    		def payload
    			event.payload
    		end
    end
  end
end