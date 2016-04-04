module Inquiry
  module Search
    module ClassMethods
      def search_clause(search_key, filter_clause, options={})
        search_clauses << SearchClause.new(search_key, filter_clause, options)
      end

      def sort_order(sort_key, sort_clause, options={})
        sort_orders << SortClause.new(sort_key, sort_clause, options)
      end

      def search(search_parameters={})
        (search_clauses + sort_orders).inject(base_scope) do |scope, query_clause|
          query_clause.apply(scope, search_parameters)
        end
      end

      private

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
