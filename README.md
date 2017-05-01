```
bundle install
bundle exec rails s

localhost:3000/items
localhost:3000/orders

app/controllers/orders_controller.rb

def create
  Payjp.api_key = "sk_test_c62fade9d045b54cd76d7036"
  customer = Payjp::Customer.create(card:payjp_token)
  plan = Payjp::Plan.create(id: "normal", amount: "500", interval: "month", currency: "jpy")
  # 管理画面でプランを作成して直接plan_idを記入するのも可能です
  subscription = Payjp::Subscription.create(customer:customer.id, plan: plan.id) # 定期購読
end
```
