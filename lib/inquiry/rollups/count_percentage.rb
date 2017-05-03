module Inquiry
  module Rollups
    class CountPercentage < Base
      def initialize(key, field_or_clause, options={})
        @field_or_clause = field_or_clause
        super
        @match = options[:match] or raise ArgumentError, "Must provide a :match value or array"
      end

      def result
        counts = query_scope.uniq.unscope(:group).group(@field_or_clause).count
        total = counts.values.sum
        if total == 0
          0
        else
          match_count = counts.slice(*@match).values.sum
          match_count / total.to_f
        end
      end
    end
  end
end
