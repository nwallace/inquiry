class Customer < ActiveRecord::Base
  has_many :orders

  def full_name
    [first_name, last_name].compact.join(" ")
  end
end
