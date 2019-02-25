class OrderSearch
  include Inquiry::Search

  search_clause :created_after, "orders.created_at >= ?"
  search_clause :status, "orders.status IN (?)"
  search_clause :customer_name, "customers.first_name LIKE ? OR customers.last_name LIKE ?", joins: :customer, type: :partial
  search_clause :last_name_starts_with, "customers.last_name LIKE ?", joins: :customer, type: :prefix
  search_clause :includes_product, "line_items.product_id = ?", joins: :line_items
  search_clause :minimum_price, "1=1", left_joins: :line_items, group: "line_items.order_id", having: "SUM(COALESCE(line_items.price, 0)) >= ?"

  sort_order :id
  sort_order :highest_price, "SUM(line_items.price) DESC", joins: :line_items, group: "line_items.order_id"
  sort_order :customer_name, "customers.last_name, customers.first_name", joins: :customer
end
