require "spec_helper"

describe Timber::Events::Exception, :rails_23 => true do
  describe ".initialize" do
    it "should clean the backtrace" do
      backtrace = [
        "/path/to/file1.rb:26:in `function1'",
        "path/to/file2.rb:86:in `function2'"
      ]

      exception_event = described_class.new(name: "RuntimeError", exception_message: "Boom", backtrace: backtrace)
      expect(exception_event.backtrace).to eq([{:file=>"/path/to/file1.rb", :line=>26, :function=>"function1"}, {:file=>"path/to/file2.rb", :line=>86, :function=>"function2"}])
    end
  end
end