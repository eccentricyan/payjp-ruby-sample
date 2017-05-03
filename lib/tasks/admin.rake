namespace :admin do
  desc 'refresh user admin'
  task :refresh => :environment do
    Order.gt(current_period_end: Time.now).each do |order|
      subscription = Payjp::Subscription.retrieve(id: order.subscription)
      if subscription.status == "active"
        order.current_period_end = Time.at(subscription.current_period_end)
        order.save!
      else
        user = order.user
        user.role.delete("#{order.item.id}_#{order.item.interval}")
        user.save!
      end
    end
  end
end
