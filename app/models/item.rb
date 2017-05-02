class Item
  include Mongoid::Document
  field :name, type: String
  field :price, type: Integer
  field :interval, type: Symbol
  validates :interval, inclusion: {in: [:month, :year]}
end
