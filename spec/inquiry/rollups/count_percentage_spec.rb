require "spec_helper"

RSpec.describe Inquiry::Rollups::CountPercentage do

  describe "#result" do
    let(:tv) { Product.create!(name: "television") }
    let(:dvd) { Product.create!(name: "DVD") }

    before {
      Order.create!(status: "complete", line_items: [
        LineItem.create!(product: tv, price: 1000),
        LineItem.create!(product: dvd, price: 15),
        LineItem.create!(product: dvd, price: 10),
      ])
      Order.create!(status: "incomplete", line_items: [
        LineItem.create!(product: tv, price: 1000),
      ])
      Order.create!(status: "complete", line_items: [
        LineItem.create!(product: dvd, price: 10),
      ])
      Order.create!(status: "paid", line_items: [
        LineItem.create!(product: dvd, price: 20),
        LineItem.create!(product: dvd, price: 15),
      ])
    }

    it "returns the percentage of results that match the given value" do
      subject = described_class.new(:incomplete_pct, :status, match: "incomplete")
      subject.query_scope = Order.all
      expect(subject.result).to eq 0.25
    end

    it "returns the percentage of results that match the given values" do
      subject = described_class.new(:conversion_pct, :status, match: ["paid", "complete"])
      subject.query_scope = Order.all
      expect(subject.result).to eq 0.75
    end
  end
end
