module Inquiry
  module Report
    InvalidColumnError = Class.new(StandardError)

    class Column
      attr_reader :key, :title, :formatter
      def initialize(key, options)
        @key = key
        @default = !!options[:default]
        @title = options[:title] || key.to_s.titleize
        @formatter = options[:formatter] || Inquiry::Formatters::Simple.new(key)
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

      protected

      def columns
        @columns ||= {}
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    attr_reader :criteria, :columns

    def initialize(criteria={})
      permitted_criteria = criteria.select {|k,v| default_criteria.has_key?(k)}
      @criteria = default_criteria.merge(permitted_criteria)
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

    def rows
      @rows ||= search_results.map {|record| Row.new(record, @columns)}
    end

    private

    def default_criteria
      search_class.search_clauses.map(&:search_key).zip([]).to_h.tap do |h|
        if default_sort_order
          h[:sort_order] = default_sort_order
        end
      end
    end

    def default_columns
      all_columns.values.select(&:default?)
    end

    def default_sort_order
      self.class.instance_variable_get("@default_sort_order")
    end

    def all_columns
      self.class.send(:columns)
    end

    def search_class
      self.class.instance_variable_get("@search_class")
    end

    def search_results
      @search_results ||= search_class.search(criteria)
    end
  end
end
