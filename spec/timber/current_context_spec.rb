require "spec_helper"

describe Timber::CurrentContext do
  describe ".initialize" do
    it "should not set the release context" do
      context = described_class.send(:new)
      expect(context.send(:hash)[:release]).to be_nil
    end

    it "should set the system context" do
      context = described_class.send(:new)
      system_content = context.fetch(:system)
      expect(system_content[:hostname]).to_not be_nil
    end

    it "should set the runtime context" do
      context = described_class.send(:new)
      runtime_context = context.fetch(:runtime)
      expect(runtime_context[:thread_id]).to_not be_nil
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
        expect(context.send(:hash)[:release]).to eq({:commit_hash=>"2c3a0b24069af49b3de35b8e8c26765c1dba9ff0", :created_at=>"2015-04-02T18:00:42Z", :version=>"v2.3.1"})
      end
    end

    context "with generic env vars" do
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
        expect(context.send(:hash)[:release]).to eq({:commit_hash=>"2c3a0b24069af49b3de35b8e8c26765c1dba9ff0", :created_at=>"2015-04-02T18:00:42Z", :version=>"v2.3.1"})
      end
    end
  end

  describe ".add" do
    after(:each) do
      described_class.reset
    end

    it "should add the context" do
      expect(described_class.instance.send(:hash)[:build]).to be_nil

      described_class.add({build: {version: "1.0.0"}})
      expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})

      described_class.add({testing: {key: "value"}})
      expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})
      expect(described_class.instance.send(:hash)[:testing]).to eq({:key=>"value"})
    end
  end

  describe ".remove" do
    it "should remove context by key" do
      context = {:build=>{:version=>"1.0.0"}}
      described_class.add(context)
      expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})

      described_class.remove(:build)
      expect(described_class.instance.send(:hash)[:build]).to be_nil
    end
  end

  describe ".with" do
    it "should merge the context and cleanup on block exit" do
      expect(described_class.instance.send(:hash)[:build]).to be_nil

      described_class.with({build: {version: "1.0.0"}}) do
        expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})

        described_class.with({testing: {key: "value"}}) do
          expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})
          expect(described_class.instance.send(:hash)[:testing]).to eq({:key=>"value"})
        end

        expect(described_class.instance.send(:hash)[:build]).to eq({:version=>"1.0.0"})
        expect(described_class.instance.send(:hash)[:testing]).to be_nil
      end

      expect(described_class.instance.send(:hash)[:build]).to be_nil
      expect(described_class.instance.send(:hash)[:testing]).to be_nil
    end
  end
end
