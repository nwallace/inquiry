class ProductSearch
  include Inquiry::Search

  search_clause :discontinued, "products.discontinued = ?"
end
