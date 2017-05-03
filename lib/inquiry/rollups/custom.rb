module Inquiry
  module Rollups
    class Custom < Base

      def initialize(key, result_proc, options={})
        @result_proc = result_proc
        super
      end

      def result
        @result_proc.call(query_scope)
      end
    end
  end
end
