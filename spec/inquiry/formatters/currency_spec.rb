require "spec_helper"

RSpec.describe Inquiry::Formatters::Currency do

  subject { described_class.new(:total_price) }

  it_behaves_like "a report value formatter"

  describe "#call" do
    let(:link) { double("the link") }
    let(:view) { double("the view", number_to_currency: "$12.99") }
    let(:brent) { Customer.create!(first_name: "Brent") }
    let(:ray_gun) { Product.create!(name: "Ray Gun") }
    let(:line_item) { LineItem.create!(product: ray_gun, price: 12.987) }
    let(:order) { Order.create!(customer: brent, line_items: [line_item]) }

    it "formats the field's value as dollars and cents by default" do
      expect(view).to receive(:number_to_currency)
        .with(12.987, {})
        .and_return "$12.99"
      expect(subject.call(view, order)).to eq "$12.99"
    end

    it "formats the field's value with any arguments configured on initialization" do
      subject = described_class.new(:total_price, precision: 0, locale: :fr)
      expect(view).to receive(:number_to_currency)
        .with(12.987, precision: 0, locale: :fr)
        .and_return "13 Euros"
      expect(subject.call(view, order)).to eq "13 Euros"
    end
  end
end
