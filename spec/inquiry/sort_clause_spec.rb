require "spec_helper"

RSpec.describe Inquiry::SortClause do

  describe "initialization" do
    it "takes the sort key, an optional sort clause, and optional options" do
      expect(described_class.new(:customer_name, "customers.last_name, customers.first_name")).to be_a described_class
      expect(described_class.new(:id, "orders.id", default: true)).to be_a described_class
      expect(described_class.new(:id)).to be_a described_class
      expect(described_class.new(:id, default: true)).to be_a described_class
    end
  end

  describe "#apply" do
    subject { described_class.new(:id, "orders.id") }

    it "applies the clause to the given scope if the specified sort order matches the sort key" do
      expect(subject.apply(Order.all, sort_order: :id).to_sql)
        .to eq Order.all.order("orders.id").to_sql
    end

    it "orders the given scope using the key as the clause when no clause is specified" do
      expect(described_class.new(:id).apply(Order.all, sort_order: :id).to_sql)
        .to eq Order.all.order('"orders"."id" ASC').to_sql
      expect(described_class.new(:id, default: true).apply(Order.all, {}).to_sql)
        .to eq Order.all.order('"orders"."id" ASC').to_sql
    end

    it "orders the given scope by the given key when the clause is a symbol" do
      expect(described_class.new(:the_id, :id).apply(Order.all, sort_order: :the_id).to_sql)
        .to eq Order.all.order('"orders"."id" ASC').to_sql
    end

    it "orders the given scope by the given keys when the clause is a list" do
      expect(described_class.new(:customer, [:customer_id, :id]).apply(Order.all, sort_order: :customer).to_sql)
        .to eq Order.all.order('"orders"."customer_id" ASC, "orders"."id" ASC').to_sql
    end

    it "returns the original scope if the sort order is unspecified" do
      original_scope = instance_double(ActiveRecord::Relation)
      expect(subject.apply(original_scope, {})).to eq original_scope
    end

    it "applies the clause to the given scope if the sort order is unspecified and it is the default" do
      subject = described_class.new(:id, "orders.id", default: true)
      expect(subject.apply(Order.all, {}).to_sql)
        .to eq Order.all.order("orders.id").to_sql
    end

    it "joins other relations when configured to do so" do
      subject = described_class.new(:customer, "customers.last_name", joins: :customer)
      expect(subject.apply(Order.all, sort_order: :customer).to_sql)
        .to eq Order.joins(:customer).order("customers.last_name").to_sql
    end

    it "groups by columns when configured to do so" do
      subject = described_class.new(:total_price, "SUM(line_items.price)", joins: :line_items, group: "line_items.order_id")
      expect(subject.apply(Order.all, sort_order: :total_price).to_sql)
        .to eq Order.joins(:line_items).order("SUM(line_items.price)").group("line_items.order_id").to_sql
    end
  end
end
