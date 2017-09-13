module Timber
  module LogDevices
    class HTTP
      # Represents an attempt to deliver a request. Requests can be retried, hence
      # why we keep track of the number of attempts.
      class RequestAttempt
        attr_reader :attempts, :request

        def initialize(req)
          @attempts = 0
          @request = req
        end

        def attempted!
          @attempts += 1
        end
      end
    end
  end
end