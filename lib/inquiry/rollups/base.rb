module Inquiry
  module Rollups
    class Base
      attr_reader :key, :title, :type
      attr_writer :query_scope

      def initialize(key, *args)
        @options = args.last.is_a?(Hash) && args.last or {}
        @key = key
        @title = @options[:title] || key.to_s.humanize.capitalize
        @type = @options[:type] || default_type
      end

      def result
        raise NotImplementedError
      end

      def to_partial_path
        "inquiry/rollups/#{type}"
      end

      protected

      def default_type
        self.class.name.demodulize.underscore
      end

      attr_reader :options, :query_scope
    end
  end
end
