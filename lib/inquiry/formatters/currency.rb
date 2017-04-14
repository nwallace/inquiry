module Inquiry
  module Formatters
    class Currency

      def initialize(method, options={})
        @method = method
        @options = options
      end

      def call(view, record)
        view.number_to_currency(record.public_send(@method), @options)
      end
    end
  end
end
