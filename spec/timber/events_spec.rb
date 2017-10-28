require "spec_helper"

describe Timber::Events, :rails_23 => true do
  describe ".build" do
    it "should build a Timber::Event" do
      event = Timber::Events::Custom.new(
        type: :payment_rejected,
        message: "Payment rejected",
        data: {customer_id: "abcd1234", amount: 100}
      )
      built_event = Timber::Events.build(event)
      expect(built_event).to eq(event)
    end

    it "should use #to_timber_event" do
      PaymentRejectedEvent = Struct.new(:customer_id, :amount) do
        def to_timber_event
          Timber::Events::Custom.new(
            type: :payment_rejected,
            message: "Payment rejected for #{customer_id}",
            data: respond_to?(:to_h) ? to_h : hash
          )
        end
      end
      built_event = Timber::Events.build(PaymentRejectedEvent.new("abcd1234", 100))
      expect(built_event).to be_kind_of(Timber::Events::Custom)
      expect(built_event.type).to eq(:payment_rejected)
      expect(built_event.message).to eq("Payment rejected for abcd1234")
      Object.send(:remove_const, :PaymentRejectedEvent)
    end

    it "should accept a properly structured hash" do
      built_event = Timber::Events.build({message: "Payment rejected", payment_rejected: {customer_id: "abcd1234", amount: 100}})
      expect(built_event).to be_kind_of(Timber::Events::Custom)
      expect(built_event.type).to eq(:payment_rejected)
      expect(built_event.message).to eq("Payment rejected")
    end

    it "should accept a struct" do
      PaymentRejectedEvent = Struct.new(:customer_id, :amount) do
        def message; "Payment rejected for #{customer_id}"; end
        def type; :payment_rejected; end
      end
      built_event = Timber::Events.build(PaymentRejectedEvent.new("abcd1234", 100))
      expect(built_event).to be_kind_of(Timber::Events::Custom)
      expect(built_event.type).to eq(:payment_rejected)
      expect(built_event.message).to eq("Payment rejected for abcd1234")
      Object.send(:remove_const, :PaymentRejectedEvent)
    end

    it "should return nil for unsupported" do
      expect(Timber::Events.build(1)).to be_nil
    end
  end
end