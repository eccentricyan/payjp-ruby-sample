class Order
  include Mongoid::Document
  field :plan, type: String
  field :customer, type: String
  has_one :item
end
