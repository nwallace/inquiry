require "spec_helper"

RSpec.describe Inquiry::SelectClause do

  describe "initialization" do
    it "takes the select key, an optional select clause, and optional options" do
      expect(described_class.new(:id)).to be_a described_class
      expect(described_class.new(:id, "customers.id")).to be_a described_class
      expect(described_class.new(:last_order_placed_at, "MAX(orders.created_at)", joins: :orders)).to be_a described_class
    end
  end

  describe "#apply" do
    it "applies the select clause to the given query scope", :aggregate_failures do
      expect(described_class.new(:id).apply(Customer.all).to_sql)
        .to eq Customer.all.select(:id).to_sql
      expect(described_class.new(:id, "customers.customer_id").apply(Customer.all).to_sql)
        .to eq Customer.all.select("customers.customer_id AS \"id\"").to_sql
    end

    it "joins other relations when configured to do so" do
      subject = described_class.new(:last_order_placed_at, "MAX(orders.created_at) >= ?", joins: :orders)
      expect(subject.apply(Customer.all).to_sql)
        .to eq Customer.joins(:orders).select("MAX(orders.created_at) >= ? AS \"last_order_placed_at\"").to_sql
    end

    it "groups by columns when configured to do so" do
      subject = described_class.new(:last_order_placed_at, "MAX(orders.created_at) >= ?", joins: :orders, group: "orders.customer_id")
      expect(subject.apply(Customer.all).to_sql)
        .to eq Customer.joins(:orders).group("orders.customer_id").select("MAX(orders.created_at) >= ? AS \"last_order_placed_at\"").to_sql
    end
  end
end
