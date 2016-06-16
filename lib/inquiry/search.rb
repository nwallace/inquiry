module Inquiry
  module Search
    module ClassMethods
      def search_clause(search_key, filter_clause, options={})
        search_clauses << SearchClause.new(search_key, filter_clause, options)
      end

      def sort_order(sort_key, sort_clause, options={})
        sort_orders << SortClause.new(sort_key, sort_clause, options)
      end

      def column(select_key, select_clause=nil, options={})
        select_clauses << SelectClause.new(select_key, select_clause, options)
      end

      def model_class(model_class)
        @model_class = model_class
      end

      def base_scope
        (@model_class || self.name.to_s.sub(/Search$/, "").constantize).all
      end

      def search(search_parameters={})
        (search_clauses + sort_orders).inject(base_scope) do |scope, query_clause|
          query_clause.apply(scope, search_parameters)
        end
      end

      def report(query_scope)
        final_query_scope = select_clauses.inject(query_scope) do |scope, select_clause|
          select_clause.apply(scope)
        end

        final_query_scope.to_a.map do |record|
          select_clauses.each_with_object({}) do |select_clause, row|
            row[select_clause.key] = record.public_send(select_clause.key)
          end
        end
      end

      private

      def search_clauses
        @search_clauses ||= []
      end

      def sort_orders
        @sort_orders ||= []
      end

      def select_clauses
        @select_clauses ||= []
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
