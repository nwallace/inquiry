class OrderReport
  include Inquiry::Report

  column :id
  column :customer_name, "customers.first_name || ' ' || customers.last_name", joins: :customer
  column :total_price, "SUM(line_items.price * line_items.quantity)", joins: :line_items, group: "orders.id"
  column :num_items, "SUM(line_items.quantity)", joins: :line_items, group: "customers.id"
  column :date_created, "orders.created_at"
end
