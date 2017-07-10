require "spec_helper"

describe Timber::Events::Error, :rails_23 => true do
  describe ".initialize" do
    it "should clean the backtrace" do
      backtrace = [
        "/path/to/file1.rb:26:in `function1'",
        "path/to/file2.rb:86:in `function2'"
      ]

      exception_event = described_class.new(name: "RuntimeError", error_message: "Boom", backtrace: backtrace)
      expect(exception_event.backtrace).to eq([{:file=>"/path/to/file1.rb", :line=>26, :function=>"function1"}, {:file=>"path/to/file2.rb", :line=>86, :function=>"function2"}])
    end

    it "parses valid lines" do
      backtrace = [
        "/path/to/file1.rb:26:in `function1'",
        "path/to/file2.rb:86" # function names are optional
      ]

      exception_event = described_class.new(name: "RuntimeError", error_message: "Boom", backtrace: backtrace)
      expect(exception_event.backtrace).to eq([{:file=>"/path/to/file1.rb", :line=>26, :function=>"function1"}, {:file=>"path/to/file2.rb", :line=>86}])
    end

    it "handles malformed lines" do
      backtrace = [
        "malformed"
      ]

      exception_event = described_class.new(name: "RuntimeError", error_message: "Boom", backtrace: backtrace)
      expect(exception_event.backtrace).to eq([{:file=>"malformed"}])
   end
  end
end