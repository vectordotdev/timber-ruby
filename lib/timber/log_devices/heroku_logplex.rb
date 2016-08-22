require File.join(File.dirname(__FILE__), "heroku_logplex", "hybrid_formatter")

module Timber
  module LogDevices
    class HerokuLogplex < IO
      def initialize(options = {})
        super(STDOUT)
        if formatter.is_a?(IO::HybridFormatter)
          formatter.extend HybridFormatter
        end
      end

      private
        def line_class
          Line
        end
    end
  end
end