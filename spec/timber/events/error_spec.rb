require "spec_helper"

describe Timber::Events::Error, :rails_23 => true do
  describe "#to_hash" do
    it "should jsonify the stacktrace" do
      backtrace = [
        "/path/to/file1.rb:26:in `function1'",
        "path/to/file2.rb:86:in `function2'"
      ]
      exception_event = described_class.new(name: "RuntimeError", error_message: "Boom", backtrace: backtrace)

      expected_hash = {
        :name => "RuntimeError",
        :message => "Boom",
        :backtrace_json => "[\"/path/to/file1.rb:26:in `function1'\",\"path/to/file2.rb:86:in `function2'\"]"
      }
      expect(exception_event.to_hash).to eq(expected_hash)
    end
  end
end