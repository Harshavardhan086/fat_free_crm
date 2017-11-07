class OrdersController < EntitiesController
  # before_action :get_data_for_sidebar, only: :index

  def new
    # @order = Order.new(user: current_user)
    @order.attributes = { user: current_user }
    @lead = Lead.new(user: current_user,access: Setting.default_access)
    @opportunity = Opportunity.new(user: current_user)
    @account = Account.new(user: current_user)
    @attachment = OrderFile.new
    @us_states = helpers.us_states
    @task = Task.new(user: current_user)
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [t(:due_specific_date, default: 'On Specific Date...'), :specific_time]
    @category = Setting.unroll(:task_category)
  end

  def create

    @from_accounts = params[:from_accounts]
    if params[:from_accounts] == "true"
      return redirect_to create_order_from_account_path, lead: params[:lead], account_id: params[:account_id], opportunity: params[:opportunity], order: params[:order]
    end
    logger.debug("OrdersController- create *********************- LEAD:  #{params[:lead].inspect}")
    logger.debug("OrdersController- create *********************- ACCOUNT:  #{params[:account].inspect}")
    logger.debug("OrdersController- create *********************- OPPORTUNITY:  #{params[:opportunity].inspect}")
    logger.debug("OrdersController- create *********************- Task: #{params[:task].inspect}")
    logger.debug("OrdersController- create *********************- ORDER Is: #{@order.inspect}")
    @us_states = helpers.us_states
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [t(:due_specific_date, default: 'On Specific Date...'), :specific_time]
    @category = Setting.unroll(:task_category)
    @attachment = OrderFile.new
    @account, @opportunity, @contact, @lead = @order.order_attributes(params.permit!)
    logger.debug("Saved Lead---- #{@lead.id}")
    logger.debug("Saved opportunity---- #{@opportunity.inspect}")
    logger.debug("Saved account---- #{@account.inspect}")
    logger.debug("Saved contact---- #{@contact.inspect}")

    @order.user_id = params[:order][:user_id]
    @order.status = params[:order][:status]
    @order.state_of_incorporate = params[:order][:state_of_incorporate]
    @order.lead_id = @lead.id
    @order.opportunity_id = @opportunity.id
    @order.account_id = @account.id
    if @order.save
      logger.debug("saving the order****************")
     # Task.create_for_order(params[:task],@order)
      Quickbook.create_quickbooks_invoice(@account, @order)
    else
      logger.debug("NOT SAVING THE ORDER************")
      @task = Task.new
    end

    respond_with(@order) do |_format|
      if called_from_index_page?
        @orders = get_orders
      end
    end
  end


  def create_order_from_account
    logger.debug("IN THE create_order_from_account****** #{params.inspect}")
    logger.debug("OrdersController- create_order_from_account *********************- LEAD:  #{params[:lead].inspect}")
    logger.debug("OrdersController- create_order_from_account *********************- ACCOUNT:  #{params[:account_id].inspect}")
    logger.debug("OrdersController- create_order_from_account *********************- OPPORTUNITY:  #{params[:opportunity].inspect}")
    logger.debug("OrdersController- create_order_from_account *********************- ORDER Is: #{@order.inspect}")
    @order = Order.new
    @opportunity, @contact, @lead = Order.order_attributes_from_accounts(params.permit!)
    @account = Account.find(params[:account_id])
    @order.user_id = params[:order][:user_id]
    @order.status = params[:order][:status]
    @order.state_of_incorporate = params[:order][:state_of_incorporate]
    @order.lead_id = @lead.id
    @order.opportunity_id = @opportunity.id
    @order.account_id = params[:account_id]

    @order.save
    # respond_with(@account) do |_format|
    #   # @accounts = get_accounts
    #   # get_data_for_sidebar
    # end

  end

  # GET /orders
  #----------------------------------------------------------------------------
  def index
    @orders = get_orders(page: params[:page])
    # @orders = Order.all

    respond_with @orders do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @orders }
    end
  end


  def edit
    @account = @order.account || Account.new(user: current_user)
    @lead = @order.lead
    @opportunity = @order.opportunity
    @us_states = helpers.us_states
    @attachments = @order.order_files
    logger.debug("Attached files are #{@attachments.inspect}")
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@order)
  end

  def update
    logger.debug("Orders Controller- update****************** : #{params.inspect}")
    logger.debug("Orders controller- update******** Lead : #{params[:lead].inspect}")
    # logger.debug("Orders controller- update******** opportunity : #{params[:opportunity].inspect}")
    @account, @opportunity, @contact, @lead = @order.order_attributes(params.permit!)
    # opportunity.update_attributes(params[:opportunity])
    @order.account_id = @account.id
    logger.debug("Orders controller- update******** Order IS: #{@order.opportunity.amount.inspect}")
    if @order.update_attributes(orders_params)
      Quickbook.update_invoice( @account,@order)
      respond_with(@order)
    end

  end

  def show
    @comment = Comment.new
    @timeline = timeline(@order)
    respond_with(@order)
  end

  # GET /orders/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:orders_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:orders_sort_by]  = Order.sort_by_map[params[:sort_by]] if params[:sort_by]
    @orders = get_orders(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@orders) do |format|
      format.js { render :index }
    end
  end


  def copy_account_details
    logger.debug("OrdersController---copy_account_details********************************")
    @account = Account.find_by_name(params[:account_name])
    @address = Address.find_by_addressable_id(@account.id)
    logger.debug("OrdersController--copy_account_details-- #{@account.inspect}")
    respond_with do |format|
      format.js
    end
  end

  def remove_attachment
    logger.debug("orders controller---remove attachment")
    @attachment_id = params[:attachment_id]
    OrderFile.destroy(@attachment_id)
  end

  def send_invoice
    logger.debug("OrdersController-----SEND INVOICE---- #{params.inspect}")
    order = Order.find(params[:order_id])
    Quickbook.send_invoice(order.qb_invoice_ref, order)
  end

  private

  alias_method :get_orders, :get_list_of_records

  def orders_params
    params.require(:order).permit(:user_id, :status, :state_of_incorporate,
                                  leads_attributes: [:user_id, :first_name, :last_name, :email, :phone, :blog, :source],
                                  opportunities_attributes: [:user_id, :stage, :amount, :discount],
                                  order_files_attributes: [:file_name, :attachment]
    )
  end
end