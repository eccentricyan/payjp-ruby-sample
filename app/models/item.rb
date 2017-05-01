class Item
  include Mongoid::Document
  field :name, type: String
  field :price, type: Integer
  belongs_to :order
end
