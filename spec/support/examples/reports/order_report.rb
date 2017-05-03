class OrderReport
  include Inquiry::Report

  # default_search_parameters status: ["paid", "complete"]
  default_sort_order :highest_price

  search_class OrderSearch

  column :id, default: true, formatter: ->(view, order) { view.link_to(order.id, order) }
  column :status, default: true
  column :customer, default: true, includes: :customer, formatter: ->(view, order) { view.link_to(order.customer.full_name, order.customer) }
  column :total_price, default: true, includes: :line_items
  column :created_at, format: ->(view, order) { view.display_date(order.created_at) }

  rollup :total_orders,    :count
  rollup :total_revenue,   :sum, "line_items.price", joins: :line_items
  rollup :num_line_items,  :count, "line_items.id", title: "Total line items"
  rollup :statuses,        :counts, :status
  rollup :conversion_rate, :count_percentage, :status, match: ["paid", "complete"]
  rollup :revenue_by_product, -> (query_scope) {
    query_scope.joins(line_items: :product)
      .unscope(:group)
      .group("products.name")
      .sum("line_items.price")
  }
end
