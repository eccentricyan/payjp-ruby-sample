class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

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
    customer = Payjp::Customer.create(card:payjp_token)
    plans = Payjp::Plan.all
    if plans.count <= 0
      plan = Payjp::Plan.create(id: "normal", amount: "500", interval: "month", currency: "jpy")
    else
      plan = plans.first
    end
    # 管理画面でプランを作成して直接plan_idを記入するのも可能です
    subscription = Payjp::Subscription.create(customer:customer.id, plan: plan.id)
    @order = Order.create(plan:plan.id, customer: customer.id)
    @order.item = item
    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {})
    end

    def payjp_token
      params["payjp-token"]
    end

    def item_id
      params.fetch(:item, {})["id"]
    end

    def item
      Item.find(item_id)
    end
end
