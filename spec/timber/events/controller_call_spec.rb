# encoding: UTF-8

require "spec_helper"

describe Timber::Events::ControllerCall, :rails_23 => true do
  describe ".initialize" do
    it "sanitizes the password param" do
      event = described_class.new(controller: 'controller', action: 'action', params: {password: 'password'})
      expect(event.params).to eq({'password' => '[sanitized]'})
    end
  end
end