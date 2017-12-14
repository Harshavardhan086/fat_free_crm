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
    @referral_sources = ReferralSource.all.collect{|rs| rs.name}
    @sales_managers = User.where(sales_manager: true).collect{|u| [u.full_name, u.id]}
    @br_files = BusinessRuleFile.all.collect{|brf| brf.file_name}
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
    @referral_sources = ReferralSource.all.collect{|rs| rs.name}
    logger.debug("Saved Lead---- #{@lead.id}")
    logger.debug("Saved opportunity---- #{@opportunity.inspect}")
    logger.debug("Saved account---- #{@account.inspect}")
    logger.debug("Saved contact---- #{@contact.inspect}")

    @order.user_id = params[:order][:user_id]
    @order.status = params[:order][:status]
    @order.state_of_incorporate = params[:order][:state_of_incorporate]
    @order.lead_id = @lead.id
    @order.name = @account.name
    @order.opportunity_id = @opportunity.id
    @order.account_id = @account.id
    # @order.assigned_to = params[:assigned_to][:assigned_to]
    @comment_body = params[:comment_body]
    br = BusinessRule.where("state_of_incorporate = ? AND request_type = ?", params[:order][:state_of_incorporate],params[:order][:request_type])
    additional_field = br.first.additional_fields.collect{|field| field.name}

    if !additional_field.blank?
      additional_field_hash = {}
      additional_field.each do |afn|
        additional_field_hash[:"#{afn}"] = params[:"#{afn}"]
      end
    end

    @order.additional_field = additional_field_hash

    br_files = br.first.business_rule_files.collect{|brf| brf.file_name}

    files_attached_to_order = []
    logger.debug("BEFORE order_files_attributes***************")
    if params[:order][:order_files_attributes]
      logger.debug("In the order_files_attributes***************")
      params[:order][:order_files_attributes].each do |k, v|
        files_attached_to_order << v[:file_name]
      end
    end

    if params[:order][:status] != "new"
      # if files_attached_to_order.sort == br_files.sort
      if (br_files-files_attached_to_order).empty?
        if @order.save
          @order.add_comment_by_user(@comment_body, current_user)
          logger.debug("saving the order************* ORDER STATUS IS: #{@order.status}")
          if @order.status != "new"
            # Task.create_for_order(params[:task],@order)
            Quickbook.create_quickbooks_invoice(@account, @order)
          end
        else
          logger.debug("NOT SAVING THE ORDER************")
          @task = Task.new
        end

        respond_with(@order) do |_format|
          if called_from_index_page?
            @orders = get_orders
          end
        end
      else
        logger.debug("Orders Controller-- create--in NOT EQUAL********************")
        @not_equal = "true"
        # @order.save
      end
    else
      if @order.save
        @order.add_comment_by_user(@comment_body, current_user)
        logger.debug("saving the order************* ORDER STATUS IS: #{@order.status}")
        if @order.status != "new"
          # Task.create_for_order(params[:task],@order)
          Quickbook.create_quickbooks_invoice(@account, @order)
        end
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
    @order.request_type = params[:order][:request_type]
    @order.lead_id = @lead.id
    @order.name = @account.name
    @order.opportunity_id = @opportunity.id
    @order.account_id = params[:account_id]
    @order.assigned_to = params[:order][:assigned_to]

    br = BusinessRule.where("state_of_incorporate = ? AND request_type = ?", params[:order][:state_of_incorporate],params[:order][:request_type])
    additional_field = br.first.additional_fields.collect{|field| field.name}

    if !additional_field.blank?
      additional_field_hash = {}
      additional_field.each do |afn|
        additional_field_hash[:"#{afn}"] = params[:"#{afn}"]
      end
    end
    @order.additional_field = additional_field_hash
    @comment_body = params[:comment_body]




    br_files = br.first.business_rule_files.collect{|brf| brf.file_name}

    files_attached_to_order = []
    logger.debug("BEFORE order_files_attributes***************")
    if params[:order][:order_files_attributes]
      logger.debug("In the order_files_attributes***************")
      params[:order][:order_files_attributes].each do |k, v|
        files_attached_to_order << v[:file_name]
      end
    end


    if params[:order][:status] != "new"
      # if files_attached_to_order.sort == br_files.sort
      if (br_files-files_attached_to_order).empty?
        if @order.save
          @order.add_comment_by_user(@comment_body, current_user)
          if @order.status != "new"
            Quickbook.create_quickbooks_invoice(@account, @order)
          end
        end
      else
        logger.debug(" Orders controller--create_order_from_account-- in NOT EQUAL********************")
        @not_equal = "true"
        # @order.save
      end
    else
      if @order.save
        @order.add_comment_by_user(@comment_body, current_user)
        if @order.status != "new"
          Quickbook.create_quickbooks_invoice(@account, @order)
        end
      end
    end


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
    @referral_sources = ReferralSource.all.collect{|rs| rs.name}
    @account = @order.account || Account.new(user: current_user)
    @lead = @order.lead
    @opportunity = @order.opportunity
    @us_states = helpers.us_states
    @attachments = @order.order_files
    @sales_managers = User.where(sales_manager: true).collect{|u| [u.full_name, u.id]}
    @br_files = BusinessRuleFile.all.collect{|brf| brf.file_name}
    logger.debug("Attached files are #{@attachments.inspect}")

    br = BusinessRule.where("state_of_incorporate = ? AND request_type = ?", @order.state_of_incorporate.to_s,@order.request_type.to_s)

    @br_attachments = br.first.business_rule_files if !br.blank?

    logger.debug("the business rule is : #{br.inspect}--------the required attached file are : #{@br_attachments.inspect}")
    @br_web = br.first.web if !br.blank?



    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@order)
  end

  def update
    @referral_sources = ReferralSource.all.collect{|rs| rs.name}
    @us_states = helpers.us_states
    @sales_managers = User.where(sales_manager: true).collect{|u| [u.full_name, u.id]}
    @br_files = BusinessRuleFile.all.collect{|brf| brf.file_name}
    @attachments = @order.order_files
    logger.debug("Orders Controller- update****************** : #{params.inspect}")
    logger.debug("Orders controller- update******** Lead : #{params[:lead].inspect}")
    # logger.debug("Orders controller- update******** opportunity : #{params[:opportunity].inspect}")
    @account, @opportunity, @contact, @lead = @order.order_attributes(params.permit!)
    # opportunity.update_attributes(params[:opportunity])
    @order.account_id = @account.id
    # @order.assigned_to = params[:assigned_to][:assigned_to]
    br = BusinessRule.where("state_of_incorporate = ? AND request_type = ?", params[:order][:state_of_incorporate],params[:order][:request_type])

    @br_web = br.first.web if !br.blank?
    @br_attachments = br.first.business_rule_files if !br.blank?
    additional_field = br.first.additional_fields.collect{|field| field.name}

    if !additional_field.blank?
      additional_field_hash = {}
      additional_field.each do |afn|
        additional_field_hash[:"#{afn}"] = params[:"#{afn}"]
      end
    end
    @order.additional_field = additional_field_hash
    @comment_body = params[:comment_body]
    logger.debug("Orders controller- update******** Order IS: #{@order.opportunity.amount.inspect}******* BR HASH: #{additional_field_hash.inspect}")

    br_files = br.first.business_rule_files.collect{|brf| brf.file_name}

    files_attached_to_order = []
    logger.debug("BEFORE order_files_attributes***************")
    if params[:order][:order_files_attributes]
      logger.debug("In the order_files_attributes***************")
      params[:order][:order_files_attributes].each do |k, v|
        files_attached_to_order << v[:file_name]
      end
    end
    files_attached = @order.order_files.collect{|f| f.file_name}

    all_order_attachment = files_attached_to_order + files_attached

    logger.debug("ALL the order attachment are************************* : #{all_order_attachment}========== BR File NAMES : #{br_files}
                        --------diffrence is : #{(br_files-all_order_attachment).empty?}")

    if params[:order][:status] != "new"
      # if all_order_attachment.sort == br_files.sort
      if (br_files-all_order_attachment).empty?
        if @order.update_attributes(orders_params)
          @order.add_comment_by_user(@comment_body, current_user)
          if @order.status != "new"
            if @order.qb_invoice_ref.nil?
              Quickbook.create_quickbooks_invoice(@account, @order)
            else
              Quickbook.update_invoice( @account,@order)
            end
          end
          respond_with(@order)
        end
      else
        # raise "Upload all the required documents."
        # @order.errors[:not_equal]
        logger.debug("Orders Controller-- update-- in NOT EQUAL********************")
        @not_equal = "true"
        @order.update_attributes(orders_params)
      end
    else
      if @order.update_attributes(orders_params)
        @order.add_comment_by_user(@comment_body, current_user)
        if @order.status != "new"
          if @order.qb_invoice_ref.nil?
            Quickbook.create_quickbooks_invoice(@account, @order)
          else
            Quickbook.update_invoice( @account,@order)
          end
        end
        respond_with(@order)
      end
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

  def create_order_invoice
    logger.debug("Orders Controller-- create_order_invoice")
    @order = Order.find(params[:order_id])

    account = @order.account

    logger.debug("the order is : #{@order.inspect}----------- Account is : #{account.inspect}")
    Quickbook.create_quickbooks_invoice(account, @order)

  end


  def populate_amount
    logger.debug("ORDERS CONTROLLER IN THE POPULATE HOURS *******************")
    state = params[:state]
    request_type = params[:type]

    br = BusinessRule.where("state_of_incorporate = ? AND request_type = ?", state.to_s,request_type.to_s)
    @amount = br.first.amount
    logger.debug("the business rule is : #{br.inspect} AND THE AMOUNT IS : #{@amount}*******
                          AND attachment is: #{br.first.business_rule_files.inspect}*******
                          AND Web is : #{br.first.web.blank?}")

    @attachments = br.first.business_rule_files
    @additional_fields = br.first.additional_fields
    @web = br.first.web
  end

  def populate_total_amount
    logger.debug("ORDERS CONTROLLER -- populate_total_amount")
    amount = params[:amount].to_i
    other = !params[:other].blank? ? params[:other].to_i : 0
    discount = !params[:discount].blank? ? params[:discount].to_i : 0

    @total = (amount + other - discount).to_s
    logger.debug("the TOTAL AMOUNT IS : #{@total}")
  end

  private

  alias_method :get_orders, :get_list_of_records

  def orders_params
    params.require(:order).permit(:user_id, :status, :state_of_incorporate,:assigned_to, :request_type, :name, :additional_field,
                                  leads_attributes: [:user_id, :first_name, :last_name, :email, :phone, :blog, :source],
                                  opportunities_attributes: [:user_id, :stage, :amount, :discount],
                                  order_files_attributes: [:file_name, :attachment]
    )
  end
end