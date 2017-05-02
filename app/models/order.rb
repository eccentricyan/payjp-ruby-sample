class Order
  include Mongoid::Document
  field :subscription, type: String
  field :current_period_end, type: DateTime
  belongs_to :item
  belongs_to :user
end
