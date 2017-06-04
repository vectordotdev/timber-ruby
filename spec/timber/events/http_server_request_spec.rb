# encoding: UTF-8

require "spec_helper"

describe Timber::Events::HTTPServerRequest, :rails_23 => true do
  describe ".initialize" do
    context "with a header filters" do
      around(:each) do |example|
        old_http_header_filters = Timber::Config.instance.http_header_filters
        Timber::Config.instance.http_header_filters += ['api-key']
        example.run
        Timber::Config.instance.http_header_filters = old_http_header_filters
      end

      it "should sanitize headers when a config option is set" do
        event = described_class.new(:headers => {'Api-Key' => 'abcde'}, :host => 'my.host.com', :method => 'GET', :path => '/path', :scheme => 'https')
        expect(event.headers).to eq({'api-key' => '[sanitized]'})
      end
    end

    it "should handle header encoding" do
      referer = 'http://www.metrojobb.se/jobb/1013893-skadeadministratör'.force_encoding('ASCII-8BIT')
      event = described_class.new(:headers => {'Referer' => referer}, :host => 'my.host.com', :method => 'GET', :path => '/path', :scheme => 'https')
      expect(event.headers.key?("referer")).to eq(false)
    end
  end
end