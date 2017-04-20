module Inquiry
  module Formatters
    class Date

      def initialize(method, format_key=nil)
        @method = method
        @format_key = format_key
      end

      def call(view, record)
        date = record.public_send(@method).try(:to_date)
        if @format_key
          date.try(:to_formatted_s, @format_key)
        else
          date.try(:to_formatted_s)
        end
      end
    end
  end
end
