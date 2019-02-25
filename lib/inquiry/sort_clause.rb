module Inquiry
  class SortClause
    attr_reader :key

    def initialize(key, sort_clause=nil, default: false, joins: nil, left_joins: nil, group: nil)
      raise ArgumentError, "You may specify either :joins or :left_joins, but not both" if joins && left_joins
      if sort_clause.is_a?(Hash)
        sort_clause.slice(:default, :joins, :left_joins, :group).keys.each do |key|
          binding.local_variable_set(key, sort_clause.delete(key)) unless binding.local_variable_get(key)
        end
      end
      @key = key
      @sort_clause = sort_clause
      @is_default = default
      @relation_to_join = joins
      @relation_to_left_join = left_joins
      @group_clause = group
    end

    def apply(scope, search_parameters)
      if search_parameters[:sort_order] == key ||
          (!search_parameters.has_key?(:sort_order) && is_default)
        if relation_to_join
          scope = scope.joins(relation_to_join)
        end
        if relation_to_left_join
          scope = scope.left_joins(relation_to_left_join)
        end
        if group_clause
          scope = scope.group(group_clause)
        end
        scope.order(sort_clause || key)
      else
        scope
      end
    end

    protected

    attr_reader :sort_clause, :is_default, :relation_to_join, :relation_to_left_join, :group_clause
  end
end
