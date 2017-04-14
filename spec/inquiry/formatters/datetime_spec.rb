require "spec_helper"

RSpec.describe Inquiry::Formatters::DateTime do

  subject { described_class.new(:created_at, :db) }

  it_behaves_like "a report value formatter"

  describe "#call" do
    let(:link) { double("the link") }
    let(:view) { double("the view") }
    let(:brent) { Customer.create!(first_name: "Brent", created_at: DateTime.new(2010, 2, 24, 8, 30, 12)) }

    it "formats the field's value according to the specified format" do
      subject = described_class.new(:created_at, :db)
      expect(subject.call(view, brent)).to eq "2010-02-24 08:30:12"

      subject = described_class.new(:created_at, :short)
      expect(subject.call(view, brent)).to eq "24 Feb 08:30"
    end
  end
end
