module Inquiry
  module Formatters
    class DateTime

      def initialize(method, format_key)
        @method = method
        @format_key = format_key
      end

      def call(view, record)
        record.public_send(@method).try(:to_formatted_s, @format_key)
      end
    end
  end
end
