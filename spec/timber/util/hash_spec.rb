require 'spec_helper'

describe Timber::Util::Hash, :rails_23 => true do
  describe "jsonify" do
    it "should return the original for simple 1 level hash" do
      original = { a: "a", b: 1, c: 123.11 }
      v = jsonify(original)
      expect(v).to eq(original)
    end

    it "should return the original when it's a multilevel hash but with supported values" do
      original = { a: "a", nested: { b: 1 } }
      v = jsonify(original)
      expect(v).to eq(original)
    end

    it "cuts out ASCII strings longer than 1000 characters from the hash" do
      file1 = ("a" * 1005).encode("ASCII-8BIT")
      file2 = ("x" * 1010).encode("ASCII-8BIT")
      original = { path: "abc", file: file1, nested: { path: "def", file: file2 } }
      v = jsonify(original)
      expect(v).to eq({ path: "abc", nested: { path: "def" } })
    end

    def jsonify(h)
      Timber::Util::Hash.jsonify(h)
    end
  end

end
