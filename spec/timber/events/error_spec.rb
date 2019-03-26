require "spec_helper"

describe Timber::Events::Error do
  describe "#to_hash" do
    it "should jsonify the stacktrace" do
      backtrace = [
        "/path/to/file1.rb:26:in `function1'",
        "path/to/file2.rb:86:in `function2'"
      ]

      exception_event = described_class.new(name: "RuntimeError", error_message: "Boom", backtrace: backtrace)
      expect(exception_event.backtrace_json).to eq("[\"/path/to/file1.rb:26:in `function1'\",\"path/to/file2.rb:86:in `function2'\"]")
    end
  end
end
