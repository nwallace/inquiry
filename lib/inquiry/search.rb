module Inquiry
  module Search
    InvalidSortOrderError = Class.new(StandardError)

    module ClassMethods
      def search_clause(search_key, filter_clause, options={})
        search_clauses << SearchClause.new(search_key, filter_clause, options)
      end

      def sort_order(key, sort_clause, options={})
        sort_orders << SortClause.new(key, sort_clause, options)
      end

      def model_class(model_class)
        @model_class = model_class
      end

      def base_scope
        (@model_class || self.name.to_s.sub(/Search$/, "").constantize).all
      end

      def search(search_parameters={})
        sort_order = search_parameters[:sort_order]
        if sort_order && sort_orders.none? {|o| o.key == sort_order.to_sym}
          raise InvalidSortOrderError, "This sort order is not defined on #{self.name}: #{sort_order.inspect}"
        elsif sort_order
          search_parameters[:sort_order] = sort_order.to_sym
        end
        (search_clauses + sort_orders).inject(base_scope) do |scope, query_clause|
          query_clause.apply(scope, search_parameters)
        end
      end

      def search_clauses
        @search_clauses ||= []
      end

      def sort_orders
        @sort_orders ||= []
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
