require "spec_helper"

RSpec.describe Inquiry::Formatters::Phone do

  subject { described_class.new(:phone) }

  it_behaves_like "a report value formatter"

  describe "#call" do
    let(:link) { double("the link") }
    let(:view) { double("the view", number_to_phone: "(555) 123-4567") }
    let(:brent) { Customer.create!(phone: "5551234567") }

    it "formats the field's value as a phone number" do
      subject = described_class.new(:phone)
      expect(view).to receive(:number_to_phone)
        .with(brent.phone, {})
        .and_return "555-123-4567"
      expect(subject.call(view, brent)).to eq "555-123-4567"

      subject = described_class.new(:phone, country_code: 1, delimiter: " ")
      expect(view).to receive(:number_to_phone)
        .with(brent.phone, country_code: 1, delimiter: " ")
        .and_return "+1 555 123 4567"
      expect(subject.call(view, brent)).to eq "+1 555 123 4567"
    end
  end
end
