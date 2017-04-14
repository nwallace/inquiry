module Inquiry
  module Formatters
    class Simple
      def initialize(field)
        @field = field
      end
      def call(view, record)
        record.public_send(@field)
      end
    end
  end
end
