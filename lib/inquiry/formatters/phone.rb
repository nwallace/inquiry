module Inquiry
  module Formatters
    class Phone

      def initialize(method, options={})
        @method = method
        @options = options
      end

      def call(view, record)
        view.number_to_phone(record.public_send(@method), @options)
      end
    end
  end
end
