require "spec_helper"

describe Timber::CurrentContext, :rails_23 => true do
  describe ".initialize" do
    it "should not set the release context" do
      context = described_class.send(:new)
      expect(context.send(:hash)).to eq({})
    end

    context "with Heroku dyno metadata" do
      around(:each) do |example|
        ENV['HEROKU_SLUG_COMMIT'] = "2c3a0b24069af49b3de35b8e8c26765c1dba9ff0"
        ENV['HEROKU_RELEASE_CREATED_AT'] = "2015-04-02T18:00:42Z"
        ENV['HEROKU_RELEASE_VERSION'] = "v2.3.1"

        example.run

        ENV.delete('HEROKU_SLUG_COMMIT')
        ENV.delete('HEROKU_RELEASE_CREATED_AT')
        ENV.delete('HEROKU_RELEASE_VERSION')

        described_class.reset
      end

      it "should automatically set the release context" do
        context = described_class.send(:new)
        expect(context.send(:hash)).to eq({:release=>{:commit_hash=>"2c3a0b24069af49b3de35b8e8c26765c1dba9ff0", :created_at=>"2015-04-02T18:00:42Z", :version=>"v2.3.1"}})
      end
    end

    context "with genric env vars" do
      around(:each) do |example|
        ENV['RELEASE_COMMIT'] = "2c3a0b24069af49b3de35b8e8c26765c1dba9ff0"
        ENV['RELEASE_CREATED_AT'] = "2015-04-02T18:00:42Z"
        ENV['RELEASE_VERSION'] = "v2.3.1"

        example.run

        ENV.delete('RELEASE_COMMIT')
        ENV.delete('RELEASE_CREATED_AT')
        ENV.delete('RELEASE_VERSION')

        described_class.reset
      end

      it "should automatically set the release context" do
        context = described_class.send(:new)
        expect(context.send(:hash)).to eq({:release=>{:commit_hash=>"2c3a0b24069af49b3de35b8e8c26765c1dba9ff0", :created_at=>"2015-04-02T18:00:42Z", :version=>"v2.3.1"}})
      end
    end
  end

  describe ".add" do
    after(:each) do
      described_class.reset
    end

    it "should add the context" do
      expect(described_class.instance.send(:hash)).to eq({})

      described_class.add({build: {version: "1.0.0"}})
      expect(described_class.instance.send(:hash)).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})

      described_class.add({testing: {key: "value"}})
      expect(described_class.instance.send(:hash)).to eq({:custom=>{:build=>{:version=>"1.0.0"}, :testing=>{:key=>"value"}}})
    end
  end

  describe ".remove" do
    it "should remove the context by object" do
      context = {:build=>{:version=>"1.0.0"}}
      described_class.add(context)
      expect(described_class.instance.send(:hash)).to eq({:custom => context})

      described_class.remove(context)
      expect(described_class.instance.send(:hash)).to eq({})
    end

    it "should remove context by key" do
      context = {:build=>{:version=>"1.0.0"}}
      described_class.add(context)
      expect(described_class.instance.send(:hash)).to eq({:custom => context})

      described_class.remove(:custom)
      expect(described_class.instance.send(:hash)).to eq({})
    end
  end

  describe ".with" do
    it "should merge the context and cleanup on block exit" do
      expect(described_class.instance.send(:hash)).to eq({})

      described_class.with({build: {version: "1.0.0"}}) do
        expect(described_class.instance.send(:hash)).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})

        described_class.with({testing: {key: "value"}}) do
          expect(described_class.instance.send(:hash)).to eq({:custom=>{:build=>{:version=>"1.0.0"}, :testing=>{:key=>"value"}}})
        end

        expect(described_class.instance.send(:hash)).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})
      end

      expect(described_class.instance.send(:hash)).to eq({})
    end
  end
end