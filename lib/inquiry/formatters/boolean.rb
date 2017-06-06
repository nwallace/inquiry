module Inquiry
  module Formatters
    class Boolean
      def initialize(field, when_true: "Yes", when_false: "No")
        @field = field
        @when_true = when_true
        @when_false = when_false
      end
      def call(view, record)
        record.public_send(@field) ? @when_true : @when_false
      end
    end
  end
end
