module Inquiry
  module Report
    InvalidColumnError = Class.new(StandardError)

    class Column
      attr_reader :key, :title, :formatter, :includes_values
      def initialize(key, options)
        @key = key
        @default = !!options[:default]
        @title = options[:title] || key.to_s.titleize
        @formatter = options[:formatter] || Inquiry::Formatters::Simple.new(key)
        @includes_values = options[:includes]
      end
      def default?
        @default
      end
    end

    class Row
      attr_reader :record
      def initialize(record, columns)
        @record = record
        @columns = columns
      end
      def values
        @values ||= @columns.map do |col|
          Value.new(@record, col.formatter)
        end
      end
    end

    class Value
      attr_reader :record, :formatter
      def initialize(record, formatter)
        @record = record
        @formatter = formatter
      end
      def render(view)
        @formatter.call(view, @record)
      end
    end

    module ClassMethods
      def search_class(klass)
        @search_class = klass
      end

      def column(key, options={})
        columns[key] = Column.new(key, options)
      end

      def default_sort_order(sort_order)
        @default_sort_order = sort_order
      end

      def permitted_criteria
        @search_class.search_clauses.map(&:search_key) << :sort_order
      end

      def rollup(key, type_or_roller_upper, *args)
        roller_upper =
          case type_or_roller_upper
          when :count; Rollups::Count.new(key, *args)
          when :counts; Rollups::Counts.new(key, *args)
          when :sum;   Rollups::Sum.new(key, *args)
          when :count_percentage; Rollups::CountPercentage.new(key, *args)
          when Proc; Rollups::Custom.new(key, type_or_roller_upper, *args)
          else; raise ArgumentError, "Invalid rollup type: #{type_or_roller_upper.inspect}. Must be one of [:count, :sum, :groups_count, :groups_count_percentage] or a proc"
          end
        rollups << roller_upper
      end

      protected

      def columns
        @columns ||= {}
      end

      def rollups
        @rollups ||= []
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    attr_reader :criteria, :columns

    def initialize(criteria={})
      if !criteria.nil?
        @pagination_options = if criteria.fetch(:paginate, true)
                                {
                                  page: criteria.delete(:page) || 1,
                                  per_page: criteria.delete(:per_page),
                                }
                              end
        safe_criteria = criteria.select {|k,v| default_criteria.has_key?(k)}
        @criteria = default_criteria.merge(safe_criteria)
        @columns = if selected_column_keys=criteria[:columns]
                     selected_column_keys.map!(&:to_sym)
                     all_columns.values_at(*selected_column_keys).tap do |cols|
                       if cols.any?(&:nil?)
                         raise InvalidColumnError, "These columns not undefined on #{self.class.name}: #{selected_column_keys.reject{|k| all_columns.has_key?(k)}.join(", ")}"
                       end
                     end
                   else
                     default_columns
                   end
      end
    end

    def rows
      @rows ||= (
        if @columns.nil?
          []
        else
          results_scope_with_includes.map {|record| Row.new(record, @columns)}
        end
      )
    end

    def results
      @results ||=
        if @pagination_options
          base_query_scope.paginate(@pagination_options)
        else
          base_query_scope
        end
    end

    def base_query_scope
      @base_query_scope ||= search_class.search(criteria)
    end

    def default_criteria
      @default_criteria ||= (
        search_class.search_clauses.map(&:search_key).zip([]).to_h.tap do |h|
          if default_sort_order
            h[:sort_order] = default_sort_order
          end
        end
      )
    end

    def default_columns
      all_columns.values.select(&:default?)
    end

    def sort_orders
      search_class.sort_orders
    end

    def all_columns
      self.class.send(:columns)
    end

    def rollups
      @rollups ||=
        all_rollups.each { |rollup| rollup.query_scope = base_query_scope }
    end

    def all_rollups
      self.class.send(:rollups)
    end

    private

    def default_sort_order
      self.class.instance_variable_get("@default_sort_order")
    end

    def search_class
      self.class.instance_variable_get("@search_class")
    end

    def results_scope_with_includes
      includes_values = (@columns || []).map(&:includes_values).reject(&:blank?)
      if includes_values.any?
        results.includes(*includes_values)
      else
        results
      end
    end
  end
end
