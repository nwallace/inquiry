module Inquiry
  module Rollups
    class Sum < Base
      def initialize(key, field_or_clause, options={})
        @field_or_clause = field_or_clause
        super
      end

      def result
        sum = query_scope.sum(@field_or_clause)
        if sum.is_a?(Hash)
          sum.values.sum
        else
          sum
        end
      end
    end
  end
end
