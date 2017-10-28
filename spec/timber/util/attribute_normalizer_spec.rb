require "spec_helper"

describe Timber::Util::AttributeNormalizer, :rails_23 => true do
  describe "#fetch" do
    it "should return nil values" do
      normalizer = described_class.new({:key => nil})
      v = normalizer.fetch(:key, :string)
      expect(v).to be_nil
    end

    it "should nillify blank strings" do
      normalizer = described_class.new({:key => ""})
      v = normalizer.fetch(:key, :string)
      expect(v).to be_nil
    end

    it "should nillify empty arrays" do
      normalizer = described_class.new({:key => []})
      v = normalizer.fetch(:key, :string)
      expect(v).to be_nil
    end

    it "should nillify empty hashes" do
      normalizer = described_class.new({:key => {}})
      v = normalizer.fetch(:key, :string)
      expect(v).to be_nil
    end

    it "should raise an error for non arrays" do
      normalizer = described_class.new({:key => "value"})
      expect(lambda { normalizer.fetch(:key, :array) }).to raise_error(ArgumentError)
    end

    it "should return arrays" do
      normalizer = described_class.new({:key => [1]})
      v = normalizer.fetch(:key, :array)
      expect(v).to eq([1])
    end

    it "should return a float with the correct precision" do
      normalizer = described_class.new({:key => 1.111111})
      v = normalizer.fetch(:key, :float, :precision => 2)
      expect(v).to eq(1.11)
    end

    it "should sanitize a hash" do
      normalizer = described_class.new({:key => {:PASSWORD => "password"}})
      v = normalizer.fetch(:key, :hash, :sanitize => ["password"])
      expect(v).to eq({"password"=>"[sanitized]"})
    end

    it "should normalize encodings" do
      value = "test".force_encoding('ASCII-8BIT')
      normalizer = described_class.new({:key => {:key => value}})
      v = normalizer.fetch(:key, :hash)
      expect(v[:key].encoding).to eq(::Encoding::UTF_8)
    end

    it "should drop large binaries" do
      value = ("a" * 1_001).force_encoding('ASCII-8BIT')
      normalizer = described_class.new({:key => {:key => value}})
      v = normalizer.fetch(:key, :hash)
      expect(v).to be_nil
    end

    it "should return an integer" do
      normalizer = described_class.new({:key => "1"})
      v = normalizer.fetch(:key, :integer)
      expect(v).to eq(1)
    end

    it "should limit a string" do
      normalizer = described_class.new({:key => "aaa"})
      v = normalizer.fetch(:key, :string, :limit => 1)
      expect(v).to eq("a")
    end

    it "should upcase a string" do
      normalizer = described_class.new({:key => "aaa"})
      v = normalizer.fetch(:key, :string, :upcase => true)
      expect(v).to eq("AAA")
    end

    it "should return a symbol" do
      normalizer = described_class.new({:key => "sym"})
      v = normalizer.fetch(:key, :symbol)
      expect(v).to eq(:sym)
    end
  end
end