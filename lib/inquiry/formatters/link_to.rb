module Inquiry
  module Formatters
    class LinkTo
      def initialize(relation=nil, options={}, &args_block)
        @relation = relation
        @args_block = args_block
        @label = options[:label] if options[:label]
        @label_method = options[:label_method] if options[:label_method]
      end

      def call(view, record)
        linked_record = @relation ? record.public_send(@relation) : record
        link_args = if @args_block
                      @args_block.call(view, linked_record)
                    elsif @label || @label_method
                      [@label || linked_record.public_send(@label_method), linked_record]
                    else
                      linked_record
                    end
        view.link_to *link_args
      end
    end
  end
end
