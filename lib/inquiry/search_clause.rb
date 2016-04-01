module Inquiry
  class SearchClause
    def initialize(search_key, filter_clause, options={})
      @search_key = search_key
      @filter_clause = filter_clause
      @options = options
    end

    def apply(scope, search_parameters)
      if match_value=search_parameters[search_key]
        if relation_to_join=options[:joins]
          scope = scope.joins(relation_to_join)
        end
        if group_clause=options[:group]
          scope = scope.group(group_clause)
          if having_clause=options[:having]
            scope = scope.having(having_clause, *match_values(having_clause, match_value))
          end
        end
        scope.where(filter_clause, *match_values(filter_clause, match_value))
      else
        scope
      end
    end

    protected

    attr_reader :search_key, :filter_clause, :options

    def match_values(clause, match_value)
      final_match_value = if options[:fuzzy]
                            "%#{match_value}%"
                          else
                            match_value
                          end
      Array.new(clause.count("?"), final_match_value)
    end
  end
end
