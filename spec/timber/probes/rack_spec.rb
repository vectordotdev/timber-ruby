require "spec_helper"

describe Timber::Probes::Rack do
  describe Timber::Probes::Rack::Middleware do
    describe ".call" do
      let(:app) do
        Rack::Builder.new do
          use Timber::Probes::Rack::Middleware
          run lambda { |env|
            [200, {'Content-Type' => 'text/plain'}, ['hello world']]
          }
        end
      end
      let(:context_class) { Timber::Contexts::RackRequest }

      def request
        Rack::MockRequest.new(app).get('/')
      end

      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
        request
      end
    end
  end
end
