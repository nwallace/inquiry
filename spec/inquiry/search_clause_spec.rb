require "spec_helper"

RSpec.describe Inquiry::SearchClause do

  describe "initialization" do
    it "takes the search key, filter clause, and optional options" do
      expect(described_class.new(:created_after, "created_at > ?")).to be_a described_class
      expect(described_class.new(:first_name, "first_name LIKE ?", type: :fuzzy)).to be_a described_class
    end
  end

  describe "#apply" do
    subject { described_class.new(:first_name, "first_name = ?") }

    it "applies the clause to the given scope using the search parameter corresponding to its search key" do
      expect(subject.apply(Order.all, first_name: "Jim").to_sql)
        .to eq Order.where("first_name = ?", "Jim").to_sql
    end

    it "returns the original scope if the search parameter is missing" do
      original_scope = instance_double(ActiveRecord::Relation)
      expect(subject.apply(original_scope, {})).to eq original_scope
    end

    it "does a fuzzy match when configured to do so" do
      subject = described_class.new(:first_name, "first_name LIKE ?", type: :fuzzy)
      expect(subject.apply(Order.all, first_name: "J").to_sql)
        .to eq Order.where("first_name LIKE ?", "%J%").to_sql
    end

    it "applies the search match value as many times as it is referenced" do
      subject = described_class.new(:name, "first_name LIKE ? OR last_name LIKE ?", type: :fuzzy)
      expect(subject.apply(Order.all, name: "J").to_sql)
        .to eq Order.where("first_name LIKE ? OR last_name LIKE ?", "%J%", "%J%").to_sql
    end

    it "joins other relations when configured to do so" do
      subject = described_class.new(:minimum_price, "SUM(line_items.price) >= ?", joins: :line_items)
      expect(subject.apply(Order.all, minimum_price: 50).to_sql)
        .to eq Order.joins(:line_items).where("SUM(line_items.price) >= ?", 50).to_sql
    end

    it "groups by columns when configured to do so" do
      subject = described_class.new(:minimum_price, "true", joins: :line_items, group: "line_items.order_id", having: "SUM(line_items.price) >= ?")
      expect(subject.apply(Order.all, minimum_price: 50).to_sql)
        .to eq Order.joins(:line_items).where("true").group("line_items.order_id").having("SUM(line_items.price) >= ?", 50).to_sql
    end
  end
end
