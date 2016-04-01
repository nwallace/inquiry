module Inquiry
  module Search
    module ClassMethods
      def search_clause(search_key, filter_clause, options={})
        @search_clauses ||= []
        @search_clauses << SearchClause.new(search_key, filter_clause, options)
      end

      def sort_order(sort_key, sort_clause, options={})
        @sort_orders ||= []
        @sort_orders << SortClause.new(sort_key, sort_clause, options)
      end

      def search(search_parameters={})
        (@search_clauses + @sort_orders).inject(model_class.all) do |scope, search_clause|
          search_clause.apply(scope, search_parameters)
        end
      end

      def model_class
        @model_class ||= self.name.to_s.sub(/Search$/, "").constantize
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
