class OrdersController < EntitiesController
  # before_action :get_data_for_sidebar, only: :index

  def new
    # @order = Order.new(user: current_user)
    @order.attributes = { user: current_user }
    @lead = Lead.new(user: current_user)
    @opportunity = Opportunity.new(user: current_user, access: "Lead", stage: "prospecting")
    @account = Account.new(user: current_user, access: "Lead")
    @us_states = us_states
    @task = Task.new(user: current_user)
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [t(:due_specific_date, default: 'On Specific Date...'), :specific_time]
    @category = Setting.unroll(:task_category)
  end

  def create
    logger.debug("OrdersController- create *********************- LEAD:  #{params[:lead].inspect}")
    logger.debug("OrdersController- create *********************- ACCOUNT:  #{params[:account].inspect}")
    logger.debug("OrdersController- create *********************- OPPORTUNITY:  #{params[:opportunity].inspect}")
    logger.debug("OrdersController- create *********************- Task: #{params[:task].inspect}")
    logger.debug("OrdersController- create *********************- ORDER Is: #{@order.inspect}")
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
    @order.save

    Task.create_for_order(params[:task],@order)

    respond_with(@order) do |_format|
      if called_from_index_page?
        @orders = get_orders
      end
    end
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
    @us_states = us_states

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@order)
  end

  def update
    logger.debug("Orders Controller- update****************** : #{params.inspect}")

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

  def us_states
    [
        ['Alabama', 'AL'],
        ['Alaska', 'AK'],
        ['Arizona', 'AZ'],
        ['Arkansas', 'AR'],
        ['California', 'CA'],
        ['Colorado', 'CO'],
        ['Connecticut', 'CT'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Florida', 'FL'],
        ['Georgia', 'GA'],
        ['Hawaii', 'HI'],
        ['Idaho', 'ID'],
        ['Illinois', 'IL'],
        ['Indiana', 'IN'],
        ['Iowa', 'IA'],
        ['Kansas', 'KS'],
        ['Kentucky', 'KY'],
        ['Louisiana', 'LA'],
        ['Maine', 'ME'],
        ['Maryland', 'MD'],
        ['Massachusetts', 'MA'],
        ['Michigan', 'MI'],
        ['Minnesota', 'MN'],
        ['Mississippi', 'MS'],
        ['Missouri', 'MO'],
        ['Montana', 'MT'],
        ['Nebraska', 'NE'],
        ['Nevada', 'NV'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New Mexico', 'NM'],
        ['New York', 'NY'],
        ['North Carolina', 'NC'],
        ['North Dakota', 'ND'],
        ['Ohio', 'OH'],
        ['Oklahoma', 'OK'],
        ['Oregon', 'OR'],
        ['Pennsylvania', 'PA'],
        ['Puerto Rico', 'PR'],
        ['Rhode Island', 'RI'],
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
        ['Vermont', 'VT'],
        ['Virginia', 'VA'],
        ['Washington', 'WA'],
        ['West Virginia', 'WV'],
        ['Wisconsin', 'WI'],
        ['Wyoming', 'WY']
    ]

  end

  private

  alias_method :get_orders, :get_list_of_records


end