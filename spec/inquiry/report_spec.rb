require "spec_helper"

RSpec.describe Inquiry::Report do
  let(:date) { Date.new(2000, 1, 1) }
  let(:fanny) { Customer.create!(first_name: "Fanny", last_name: "Billings") }
  let(:brent) { Customer.create!(first_name: "Brent", last_name: "Frank") }
  let(:ray_gun) { Product.create!(name: "Ray Gun") }
  let(:evil_lair) { Product.create!(name: "Evil Lair") }
  let(:fabric) { Product.create!(name: "Fabric") }
  let(:thimble) { Product.create!(name: "Thimble") }
  let!(:brent_order) { Order.create!(customer: brent, created_at: date + 1.day, status: "pending",
                             line_items: [LineItem.create!(product: fabric, price: 15),
                                          LineItem.create!(product: thimble, price: 3)]) }
  let!(:fanny_order) { Order.create!(customer: fanny, created_at: date - 1.day, status: "complete",
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

    it "returns only the first page of results when paginating" do
      subject = OrderReport.new(per_page: 1)
      expect(subject.rows.count).to eq 1
      expect(subject.results.total_entries).to eq 2
    end

    it "returns all results when not paginating" do
      30.times do |i|
        Order.create!(customer: brent, created_at: date - i.days,
                      line_items: [LineItem.create!(product: fabric, price: 2*i)])
      end
      subject = OrderReport.new(paginate: false)
      expect(subject.rows.count).to eq 32
      expect(subject.results.to_a.count).to eq 32
    end

    it "returns rows in the report's default order when order is not specified" do
      expect(OrderReport.new.rows.map(&:record)).to eq [fanny_order, brent_order]
    end

    it "returns rows in the specified order when order is specified" do
      expect(OrderReport.new(sort_order: :customer_name).rows.map(&:record)).to eq [fanny_order, brent_order]
    end

    it "includes any associated records that a column specifies to include" do
      30.times do |i|
        Order.create!(customer: brent, created_at: date - i.days,
                      line_items: [LineItem.create!(product: fabric, price: 2*i)])
      end
      view = double("the view").as_null_object
      subject = OrderReport.new(columns: [:customer, :total_price])
      expect { subject.rows.map(&:values).flatten.each {|v| v.render(view)} }.not_to exceed_query_limit(3)
    end
  end

  describe "#results" do
    let!(:brent_order_2) { Order.create!(customer: brent, line_items: [
      LineItem.create!(product: fabric, price: 15)]) }
    let!(:brent_order_3) { Order.create!(customer: brent, line_items: [
      LineItem.create!(product: fabric, price: 15)]) }
    let!(:fanny_order_2) { Order.create!(customer: fanny, line_items: [
      LineItem.create!(product: fabric, price: 15)]) }
    let!(:fanny_order_3) { Order.create!(customer: fanny, line_items: [
      LineItem.create!(product: fabric, price: 15)]) }

    it "returns the search query scope paginated with WillPaginate" do
      results = OrderReport.new.results
      expect(results.total_entries).to eq 6
      expect(results.to_a.count).to eq 6
      expect(results.current_page).to eq 1
      expect(results.total_pages).to eq 1
    end

    it "incorporates pagination options from initialization" do
      results = OrderReport.new(per_page: 2, page: 2).results
      expect(results.total_entries).to eq 6
      expect(results.to_a.count).to eq 2
      expect(results.current_page).to eq 2
      expect(results.total_pages).to eq 3
    end
  end

  describe "#default_criteria" do
    it "returns the default search criteria of the search class" do
      expected_criteria = {
       created_after: nil,
       customer_name: nil,
       includes_product: nil,
       last_name_starts_with: nil,
       minimum_price: nil,
       sort_order: :highest_price,
       status: nil,
      }
      expect(OrderReport.new.default_criteria).to eq(expected_criteria)
      expect(OrderReport.new(created_after: 2.days.ago, sort_order: :id).default_criteria).to eq(expected_criteria)
    end
  end

  describe "#default_columns" do
    it "returns the default columns of the search class" do
      expected_columns = [:id, :status, :customer, :total_price]
      expect(OrderReport.new.default_columns.map(&:key)).to eq(expected_columns)
      expect(OrderReport.new(columns: [:id, :created_at]).default_columns.map(&:key)).to eq(expected_columns)
    end
  end

  describe "#sort_orders" do
    it "delegates to the search class" do
      expect(OrderSearch).to receive(:sort_orders).and_return sort_orders=double("the sort orders")
      expect(OrderReport.new.sort_orders).to eq sort_orders
    end
  end

  describe "#rollups" do
    subject { OrderReport.new(status: ["paid", "complete", "pending"]) }

    it "returns all the configured rollups" do
      Order.create!(customer: brent, created_at: date + 1.day, status: "pending",
                    line_items: [LineItem.create!(product: fabric, price: 10)])
      Order.create!(customer: brent, created_at: date + 1.day, status: "pending",
                    line_items: [LineItem.create!(product: fabric, price: 10)])
      rollups = subject.rollups
      expect(rollups.count).to eq 6
      expect(rollups.map(&:class)).to eq [
        Inquiry::Rollups::Count, Inquiry::Rollups::Sum, Inquiry::Rollups::Count,
        Inquiry::Rollups::Counts, Inquiry::Rollups::CountPercentage, Inquiry::Rollups::Custom,
      ]
      expect(rollups[4].result).to eq 0.25
      expect(rollups.map(&:title)).to eq [
        "Total orders", "Total revenue", "Total line items",
        "Statuses", "Conversion rate", "Revenue by product",
      ]
      expect(rollups.map(&:result)).to eq [
        4, 2138, 6,
        { "pending" => 3, "complete" => 1 },
        0.25,
        { "Fabric" => 35, "Thimble" => 3, "Ray Gun" => 100, "Evil Lair" => 2000 },
      ]
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
