module Inquiry
  module Rollups
    class CountPercentage < Base
      def initialize(key, field_or_clause, options={})
        @field_or_clause = field_or_clause
        super
        begin
          @match = options.fetch(:match)
        rescue KeyError
          raise ArgumentError, "Must provide a :match value or array"
        end
      end

      def result
        sanitized_match_values = Array(@match).map do |match|
          ActiveRecord::Base.sanitize(match)
        end
        primary_key = "#{query_scope.table_name}.#{query_scope.primary_key}"
        counts = query_scope.unscope(:group, :order)
          .group("1")
          .pluck(
            "CASE WHEN #{@field_or_clause} IN (#{sanitized_match_values.join(",")}) THEN 'yes' ELSE 'no' END AS is_match",
            "count(DISTINCT #{primary_key}) AS count"
          ).to_h
        total = counts.values.sum
        if total == 0
          0
        else
          counts.fetch("yes", 0) / total.to_f
        end
      end

      protected

      def default_type
        "percentage"
      end
    end
  end
end
