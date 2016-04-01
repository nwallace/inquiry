module Inquiry
  class SelectClause
    attr_reader :key

    def initialize(key, clause=nil, options={})
      @key = key
      @clause = clause
      @options = options
    end

    def apply(original_scope)
      scope = original_scope.select(key_or_clause)
      if relation_to_join=options[:joins]
        scope = scope.joins(relation_to_join)
      end
      if group_clause=options[:group]
        scope = scope.group(group_clause)
      end
      scope
    end

    private

    attr_reader :clause, :options

    def key_or_clause
      @key_or_clause ||= (
        if clause
          "#{clause} AS #{key.to_s.inspect}"
        else
          key
        end
      )
    end
  end
end
