class OrderReport
  include Inquiry::Report

  default_sort_order :highest_price

  search_class OrderSearch

  column :id, default: true, formatter: ->(view, order) { view.link_to(order.id, order) }
  column :status, default: true
  column :customer, default: true, include: :customers, formatter: ->(view, order) { view.link_to(order.customer.name, order.customer) }
  column :total_price, default: true, include: :line_items
  column :created_at, format: ->(view, order) { view.display_date(order.created_at) }
end
