require "spec_helper"

RSpec.describe Inquiry::Report do

  describe ".report" do
    let(:date) { Date.new(2000, 1, 1) }
    let(:fanny) { Customer.create!(first_name: "Fanny", last_name: "Billings") }
    let(:brent) { Customer.create!(first_name: "Brent", last_name: "Frank") }
    let(:ray_gun) { Product.create!(name: "Ray Gun") }
    let(:evil_lair) { Product.create!(name: "Evil Lair") }
    let(:fabric) { Product.create!(name: "Fabric") }
    let(:thimble) { Product.create!(name: "Thimble") }
    let!(:brent_order) { Order.create!(customer: brent, created_at: date + 1.day,
                                       line_items: [LineItem.create!(product: fabric, price: 15, quantity: 1),
                                                    LineItem.create!(product: thimble, price: 3, quantity: 2)]) }
    let!(:fanny_order) { Order.create!(customer: fanny, created_at: date - 1.day,
                                       line_items: [LineItem.create!(product: ray_gun, price: 100, quantity: 1),
                                                    LineItem.create!(product: evil_lair, price: 2000, quantity: 1)]) }

    it "returns report data for the given query scope" do
      expect(OrderReport.report(Order.all)).to match_array [
        {
          id: brent_order.id,
          customer_name: "Brent Frank",
          total_price: 21,
          num_items: 3,
          date_created: brent_order.created_at.strftime("%Y-%m-%d"),
        },
        {
          id: fanny_order.id,
          customer_name: "Fanny Billings",
          total_price: 2100,
          num_items: 2,
          date_created: fanny_order.created_at.strftime("%Y-%m-%d"),
        },
      ]
    end
  end
end
