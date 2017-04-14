require "spec_helper"

RSpec.describe Inquiry::Report do
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

  describe "initialization, #criteria" do
    it "doesn't need any input" do
      subject = OrderReport.new
      expect(subject.criteria).to eq(
        created_after: nil,
        status: nil,
        customer_name: nil,
        last_name_starts_with: nil,
        includes_product: nil,
        minimum_price: nil,
        sort_order: :highest_price,
      )
    end

    it "takes the search criteria" do
      subject = OrderReport.new(
        status: ["paid"],
        last_name_starts_with: "W",
        invalid_param: "something",
        sort_order: :id,
      )
      expect(subject.criteria).to eq(
        created_after: nil,
        status: ["paid"],
        customer_name: nil,
        last_name_starts_with: "W",
        includes_product: nil,
        minimum_price: nil,
        sort_order: :id,
      )
    end

    it "raises an error when given undefined columns to select" do
      expect {
        OrderReport.new(columns: [:id, :unknown, :another])
      }.to raise_error described_class::InvalidColumnError
    end
  end

  describe "#columns" do
    it "returns the default columns when unspecified" do
      expect(OrderReport.new.columns.map(&:key)).to eq [
        :id,
        :status,
        :customer,
        :total_price,
      ]
    end

    it "returns the specified columns when specified" do
      expect(OrderReport.new(columns: [:status, :id, :created_at]).columns.map(&:key)).to eq [
        :status,
        :id,
        :created_at,
      ]
    end
  end

  describe "#rows" do
    it "returns the rows matching your search" do
      blank = OrderReport.new.rows
      expect(blank.count).to eq 2
      expect(blank.map(&:record)).to match_array [brent_order, fanny_order]

      filtered = OrderReport.new(created_after: date).rows
      expect(filtered.count).to eq 1
      expect(filtered.map(&:record)).to match_array [brent_order]
    end

    it "returns only the first page of results when paginating" # ? could be an initialization argument

    it "returns rows in the report's default order when order is not specified" do
      expect(OrderReport.new.rows.map(&:record)).to eq [fanny_order, brent_order]
    end

    it "returns rows in the specified order when order is specified" do
      expect(OrderReport.new(sort_order: :customer_name).rows.map(&:record)).to eq [fanny_order, brent_order]
    end
  end

  describe described_class::Column do
    describe "initialization" do
      it "takes the column key and configuration options" do
        subject = described_class.new(:the_key, {})
        expect(subject.key).to eq :the_key
      end
    end

    describe "#default?" do
      it "is false when unspecified" do
        expect(described_class.new(:key, {})).not_to be_default
      end

      it "is true when specified as such" do
        expect(described_class.new(:key, default: true)).to be_default
      end

      it "is false when specified as such" do
        expect(described_class.new(:key, default: false)).not_to be_default
      end
    end

    describe "#title" do
      it "tilteizes the given key when unspecified" do
        subject = described_class.new(:a_column, {})
        expect(subject.title).to eq "A Column"
      end

      it "returns the given title when specified" do
        subject = described_class.new(:a_column, title: "My Title")
        expect(subject.title).to eq "My Title"
      end
    end
  end

  describe described_class::Row do
    let(:id_col)    { Inquiry::Report::Column.new(:id, formatter: :id_formatter) }
    let(:price_col) { Inquiry::Report::Column.new(:total_price, formatter: :price_formatter) }

    describe "initializaiton" do
      it "takes an ActiveRecord record and a list of columns" do
        subject = described_class.new(brent_order, [id_col, price_col])
        expect(subject.record).to eq brent_order
      end
    end

    describe "#values" do
      it "returns the record's values for the given columns" do
        subject = described_class.new(brent_order, [id_col, price_col])
        expect(subject.values.map(&:class)).to eq [Inquiry::Report::Value, Inquiry::Report::Value]
        expect(subject.values.map(&:record)).to eq [brent_order, brent_order]
        expect(subject.values.map(&:formatter)).to eq [:id_formatter, :price_formatter]
      end

      it "returns the record's values for the given columns in the given order" do
        subject = described_class.new(brent_order, [price_col, id_col])
        expect(subject.values.map(&:formatter)).to eq [:price_formatter, :id_formatter]
      end
    end
  end
end
