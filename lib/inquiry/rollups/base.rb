module Inquiry
  module Rollups
    class Base
      attr_reader :key, :title
      attr_writer :query_scope

      def initialize(key, *args)
        @options = args.last.is_a?(Hash) && args.last or {}
        @key = key
        @title = @options[:title] || key.to_s.humanize.capitalize
      end

      def result
        raise NotImplementedError
      end

      protected

      attr_reader :options, :query_scope
    end
  end
end
