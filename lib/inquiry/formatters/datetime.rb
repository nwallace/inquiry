module Inquiry
  module Formatters
    class DateTime

      def initialize(method, format_key=nil)
        @method = method
        @format_key = format_key
      end

      def call(view, record)
        date_or_time = record.public_send(@method)
        if @format_key
          date_or_time.try(:to_formatted_s, @format_key)
        else
          record.public_send(@method).try(:to_formatted_s)
        end
      end
    end
  end
end
