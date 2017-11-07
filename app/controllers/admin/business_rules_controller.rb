class Admin::BusinessRulesController < Admin::ApplicationController
  before_action "set_current_tab('admin/business_rules')", only: [:index]

  def index
    @all_business_rules = BusinessRule.all
  end

  def new
    logger.debug("businessRules controller ---------- new")
    @business_rule = BusinessRule.new
    @us_states = helpers.us_states

  end

  def create
    logger.debug("businessRules controlled ************* create")
    business_rule = BusinessRule.new
    business_rule.state_of_incorporate = params[:business_rule][:state_of_incorporate]
    business_rule.amount = params[:business_rule][:amount]
    business_rule.request_type = params[:business_rule][:request_type]
    business_rule.web = params[:business_rule][:web]

    br_for_state = BusinessRule.where(state_of_incorporate: params[:business_rule][:state_of_incorporate])
    request_type_array = Array.new
    br_for_state.each do |br|
      br_request_type = br.request_type
      request_type_array.push(br_request_type)
    end
    logger.debug("THE REQUEST TYPES FOR STATES #{params[:business_rule][:state_of_incorporate]} are ********** #{request_type_array.inspect}")

    if request_type_array.include?(params[:business_rule][:request_type])
      @new_business_rule = "false"

    else
      @new_business_rule = "true"
      business_rule.save
    end


  end

  def edit

  end

  def update

  end

  private

  def business_rule_params
    params.require(:business_rule).permit(:state_of_incorporate, :amount, :request_type ,{documents: []})
  end

end