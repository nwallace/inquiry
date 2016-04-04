require "spec_helper"

RSpec.describe Inquiry::Search do

  class OrderSearch
    include Inquiry::Search

    search_clause :created_after, "orders.created_at >= ?"
    search_clause :customer_name, "customers.first_name LIKE ? OR customers.last_name LIKE ?", joins: :customer, type: :fuzzy
    search_clause :last_name_starts_with, "customers.last_name LIKE ?", joins: :customer, type: :prefix
    search_clause :includes_product, "line_items.product_id = ?", joins: :line_items
    search_clause :minimum_price, "1=1", joins: :line_items, group: "line_items.order_id", having: "SUM(line_items.price) >= ?"

    sort_order :id, "orders.id ASC", default: true
    sort_order :highest_price, "SUM(line_items.price) DESC", joins: :line_items, group: "line_items.order_id"
    sort_order :customer_name, "customers.last_name, customers.first_name", joins: :customer
  end

  describe ".search" do
    let(:date) { Date.new(2000, 1, 1) }
    let(:fanny) { Customer.create!(first_name: "Fanny", last_name: "Billings") }
    let(:brent) { Customer.create!(first_name: "Brent", last_name: "Frank") }
    let(:ray_gun) { Product.create!(name: "Ray Gun") }
    let(:evil_lair) { Product.create!(name: "Evil Lair") }
    let(:fabric) { Product.create!(name: "Fabric") }
    let(:thimble) { Product.create!(name: "Thimble") }
    let!(:brent_order) { Order.create!(customer: brent, created_at: date + 1.day,
                               line_items: [LineItem.create!(product: fabric, price: 15),
                                            LineItem.create!(product: thimble, price: 3)]) }
    let!(:fanny_order) { Order.create!(customer: fanny, created_at: date - 1.day,
                               line_items: [LineItem.create!(product: ray_gun, price: 100),
                                            LineItem.create!(product: evil_lair, price: 2000)]) }

    it "returns the search scope" do
      expect(OrderSearch.search).to be_a ActiveRecord::Relation
    end

    it "filters by the configured search terms", :aggregate_failures do
      expect(OrderSearch.search(created_after: date)).to match_array [brent_order]
      expect(OrderSearch.search(customer_name: "Brent")).to match_array [brent_order]
      expect(OrderSearch.search(customer_name: "F")).to match_array [fanny_order, brent_order]
      expect(OrderSearch.search(last_name_starts_with: "F")).to match_array [brent_order]
      expect(OrderSearch.search(includes_product: ray_gun.id)).to match_array [fanny_order]
      expect(OrderSearch.search(minimum_price: 100)).to match_array [fanny_order]
      expect(OrderSearch.search(minimum_price: 100, created_after: date)).to match_array []
      expect(OrderSearch.search(minimum_price: 1, customer_name: "F")).to match_array [fanny_order, brent_order]
    end

    it "sorts by the specified sort order", :aggregate_failures do
      expect(OrderSearch.search(sort_order: :id)).to eq [brent_order, fanny_order]
      expect(OrderSearch.search(sort_order: :highest_price)).to eq [fanny_order, brent_order]
      expect(OrderSearch.search(sort_order: :customer_name)).to eq [fanny_order, brent_order]
    end

    it "sorts by the default sort order, if one is configured and none is specified" do
      expect(OrderSearch.search).to eq [brent_order, fanny_order]
    end
  end
end
