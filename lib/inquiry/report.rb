module Inquiry
  module Report
    module ClassMethods
      def column(select_key, select_clause=nil, options={})
        select_clauses << SelectClause.new(select_key, select_clause, options)
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

      def select_clauses
        @select_clauses ||= []
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
