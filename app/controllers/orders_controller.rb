class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_item, only: [:index, :create]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    Payjp.api_key = "sk_test_c62fade9d045b54cd76d7036"
    @user = user

    if customer_id = @user.customer_id
      customer = Payjp::Customer.retrieve(id: customer_id)
    else
      customer = Payjp::Customer.create(card:payjp_token)
      @user.customer_id = customer.id
      @user.save!
    end

    plans = customer.subscriptions.data.collect(&:plan).collect(&:id)
    plan_id = "#{@item.id}_#{@item.interval}"
    if plans.include?(plan_id)
      plan = Payjp::Plan.retrieve(id: "#{@item.id}_#{@item.interval}")
      subscription = customer.subscriptions.data.select{|data| data.plan.id == plan_id}.first
      if subscription
        unless subscription.status == "active"
          subscription.resume
        end
        update_role(subscription)
      else
        subscription = Payjp::Subscription.create(customer:customer.id, plan: plan.id)
        update_role(subscription)
      end
    else
      plan = Payjp::Plan.create(id: "#{@item.id}_#{@item.interval}", amount: "#{@item.price}", interval: "#{@item.interval}", currency: "jpy")
      subscription = Payjp::Subscription.create(customer:customer.id, plan: plan.id)
      update_role(subscription)
    end

    if subscription
      @order = Order.find_or_create_by(subscription: subscription.id)
      @order.item = item
      @order.user = @user
      @order.current_period_end = Time.at(subscription.current_period_end)
      @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      redirect_to new, notice: 'Order was not created.'
    end

  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    Payjp.api_key = "sk_test_c62fade9d045b54cd76d7036"
    begin
      subscription = Payjp::Subscription.retrieve(id: @order.subscription)
      case status
      when "cancel"
        subscription.cancel
      when "pause"
        subscription.pause
      end
    rescue => e
    end
    @user = @order.user
    @item = @order.item
    update_role(subscription)
    redirect_back(fallback_location: item_orders_path(@order.item))
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    item = @order.item
    @order.destroy
    redirect_back(fallback_location: item_orders_path(item))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def set_item
      @item = Item.find(item_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {})
    end

    def status
      params.fetch(:order, {})["status"]
    end

    def payjp_token
      params["payjp-token"]
    end

    def item_id
      params[:item_id]
    end

    def item
      Item.find(item_id)
    end

    def user
      user = User.first
      unless user
        user = User.create(name: "payjp_user")
      end
      user
    end

    def update_role(subscription)
      if subscription.status == "active"
        @user.role << "#{@item.interval}_subscribed"
        @user.role = @user.role.uniq
        @user.save!
      else
        @user.role.delete("#{@item.interval}_subscribed")
        @user.save!
      end
    end
end
