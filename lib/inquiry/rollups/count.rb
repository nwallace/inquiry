module Inquiry
  module Rollups
    class Count < Base
      def initialize(key, field_or_clause=nil, options={})
        if field_or_clause.is_a?(Hash)
          options = field_or_clause.merge(options)
          field_or_clause = nil
        end
        @field_or_clause = field_or_clause
        super(key, options)
      end

      def result
        count = if @field_or_clause
                  query_scope.distinct.count(@field_or_clause)
                else
                  query_scope.distinct.count
                end
        if count.is_a?(Hash)
          count.values.sum
        else
          count
        end
      end

      protected

      def default_type
        "value"
      end
    end
  end
end
