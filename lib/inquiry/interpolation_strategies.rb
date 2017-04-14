module Inquiry
  module InterpolationStrategies
    {
      "Exact" => ->(value) { value },
      "Partial" => ->(value) { "%#{value}%" },
      "Prefix" => ->(value) { "#{value}%" },
      "Suffix" => ->(value) { "%#{value}" },
    }.each do |type, interpolation_strategy|
      klass = Class.new do
        define_singleton_method(:match_value, &interpolation_strategy)
      end
      const_set(type, klass)
    end
  end
end
