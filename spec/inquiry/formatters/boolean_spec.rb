require "spec_helper"

RSpec.describe Inquiry::Formatters::Boolean do

  subject { described_class.new(:discontinued) }

  it_behaves_like "a report value formatter"

  describe "#call" do
    let(:view) { double("the view") }
    let(:record) { double("the record") }

    it "returns 'Yes' when the record's field value is true" do
      allow(record).to receive(:discontinued).and_return true
      expect(subject.call(view, record)).to eq "Yes"
    end

    it "returns 'No' when the record's field value is false" do
      allow(record).to receive(:discontinued).and_return false
      expect(subject.call(view, record)).to eq "No"
    end

    context "with custom overrides" do
      subject { described_class.new(:discontinued, when_true: "Discontinued", when_false: "Active") }

      it "returns the configured true value when the record's field value is true" do
        allow(record).to receive(:discontinued).and_return true
        expect(subject.call(view, record)).to eq "Discontinued"
      end

      it "returns the configured true value when the record's field value is true" do
        allow(record).to receive(:discontinued).and_return false
        expect(subject.call(view, record)).to eq "Active"
      end
    end
  end
end

