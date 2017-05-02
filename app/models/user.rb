class User
  include Mongoid::Document
  field :name, type: String
  field :role, type: Array, default: []
  field :customer_id, type: String
end
