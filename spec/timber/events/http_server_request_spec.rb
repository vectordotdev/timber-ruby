require "spec_helper"

describe Timber::Events::HTTPServerRequest, :rails_23 => true do
  describe ".initialize" do
    context "with a header filters" do
      around(:each) do |example|
        old_header_filters = Timber::Config.instance.header_filters
        Timber::Config.instance.header_filters += ['api-key']
        example.run
        Timber::Config.instance.header_filters = old_header_filters
      end

      it "should sanitize headers when a config option is set" do
        custom_context = described_class.new(:headers => {'Api-Key' => 'abcde'}, :host => 'my.host.com', :method => 'GET', :path => '/path', :scheme => 'https')
        expect(custom_context.headers).to eq({'api-key' => '[sanitized]'})
      end
    end
  end
end