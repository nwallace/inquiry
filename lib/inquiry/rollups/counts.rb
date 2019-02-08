module Inquiry
  module Rollups
    class Counts < Base
      def initialize(key, field_or_clause, options={})
        @field_or_clause = field_or_clause
        super
      end

      def result
        query_scope.distinct.unscope(:group, :order).group(@field_or_clause).count
      end

      protected

      def default_type
        "list"
      end
    end
  end
end
