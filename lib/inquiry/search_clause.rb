module Inquiry
  class SearchClause

    attr_reader :search_key, :filter_clause, :interpolation_type, :relation_to_join, :relation_to_left_join, :group_clause, :having_clause

    def initialize(search_key, filter_clause, type: :exact, joins: nil, left_joins: nil, group: nil, having: nil)
      raise ArgumentError, "You may specify either :joins or :left_joins, but not both" if joins && left_joins
      @search_key = search_key
      @filter_clause = filter_clause
      @interpolation_type = type
      @relation_to_join = joins
      @relation_to_left_join = left_joins
      @group_clause = group
      @having_clause = having
    end

    def apply(scope, search_parameters)
      if search_parameters.has_key?(search_key) && !search_parameters[search_key].nil?
        match_value = search_parameters[search_key]
        if relation_to_join
          scope = scope.joins(relation_to_join)
        end
        if relation_to_left_join
          scope = scope.left_joins(relation_to_left_join)
        end
        if group_clause
          scope = scope.group(group_clause)
          if having_clause
            scope = scope.having(having_clause, *match_values(having_clause, match_value))
          end
        end
        scope.where(filter_clause, *match_values(filter_clause, match_value))
      else
        scope
      end
    end

    protected

    def interpolation_strategy
      @interpolation_strategy ||= (
        Inquiry::InterpolationStrategies.const_get(interpolation_type.to_s.classify)
      )
    end

    def match_values(clause, match_value)
      final_match_value = interpolation_strategy.match_value(match_value)
      Array.new(clause.count("?"), final_match_value)
    end
  end
end
