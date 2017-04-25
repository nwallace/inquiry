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
end
