module Inquiry
  class SortClause
    attr_reader :key
    def initialize(key, sort_clause, options={})
      @key = key
      @sort_clause = sort_clause
      @options = options
    end

    def apply(scope, search_parameters)
      if search_parameters[:sort_order] == key ||
          (!search_parameters.has_key?(:sort_order) && options[:default])
        if relation_to_join=options[:joins]
          scope = scope.joins(relation_to_join)
        end
        if group_clause=options[:group]
          scope = scope.group(group_clause)
        end
        scope.order(sort_clause)
      else
        scope
      end
    end

    protected

    attr_reader :sort_clause, :options
  end
end
