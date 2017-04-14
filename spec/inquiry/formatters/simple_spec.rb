require "spec_helper"

RSpec.describe Inquiry::Formatters::Simple do

  subject { described_class.new(:id) }

  it_behaves_like "a report value formatter"

  describe "#call" do
    let(:view) { double("the view") }
    let(:record) { double("the record", id: "the-id") }

    it "returns the given record's field" do
      expect(subject.call(view, record)).to eq "the-id"
    end
  end
end
