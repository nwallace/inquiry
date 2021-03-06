module Inquiry
  module InterpolationStrategies
    {
      "Exact"   => ->(value) { value },
      "Partial" => ->(value) { "%#{value}%" },
      "Prefix"  => ->(value) { "#{value}%" },
      "Suffix"  => ->(value) { "%#{value}" },
      "Truth"   => ->(value) { value && value != "0" && value !~ /\A(false|no)\Z/i },
    }.each do |type, interpolation_strategy|
      klass = Class.new do
        define_singleton_method(:match_value, &interpolation_strategy)
      end
      const_set(type, klass)
    end
  end
end
