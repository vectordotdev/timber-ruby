require "spec_helper"

describe Timber::Contexts, :rails_23 => true do
  describe ".build" do
    it "should build a Timber::Context" do
      context = Timber::Contexts::Custom.new(
        type: :build,
        data: {version: "1.0.0"}
      )
      built_context = Timber::Contexts.build(context)
      expect(built_context).to eq(context)
    end

    it "should use #to_timber_context" do
      BuildContext = Struct.new(:version) do
        def to_timber_context
          Timber::Contexts::Custom.new(
            type: :build,
            data: respond_to?(:to_h) ? to_h : Timber::Util::Struct.to_hash(self)
          )
        end
      end
      built_context = Timber::Contexts.build(BuildContext.new("1.0.0"))
      expect(built_context).to be_kind_of(Timber::Contexts::Custom)
      expect(built_context.type).to eq(:build)
      Object.send(:remove_const, :BuildContext)
    end

    it "should accept a properly structured hash" do
      built_context = Timber::Contexts.build(build: {version: "1.0.0"})
      expect(built_context).to be_kind_of(Timber::Contexts::Custom)
      expect(built_context.type).to eq(:build)
    end

    it "should accept a struct" do
      BuildContext = Struct.new(:version) do
        def type; :build; end
      end
      built_context = Timber::Contexts.build(BuildContext.new("1.0.0"))
      expect(built_context).to be_kind_of(Timber::Contexts::Custom)
      expect(built_context.type).to eq(:build)
      Object.send(:remove_const, :BuildContext)
    end

    it "should return nil for unsupported" do
      expect(Timber::Contexts.build(1)).to be_nil
    end
  end
end