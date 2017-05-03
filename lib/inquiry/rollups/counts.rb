module Inquiry
  module Rollups
    class Counts < Base
      def initialize(key, field_or_clause, options={})
        @field_or_clause = field_or_clause
        super
      end

      def result
        query_scope.uniq.unscope(:group).group(@field_or_clause).count
      end
    end
  end
end
