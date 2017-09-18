class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :lead
  belongs_to :opportunity
  has_many :contacts

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: [ "created_at DESC", "updated_at DESC"], default: "created_at DESC"



  def order_attributes(params)
    account_params = params[:account] ? params[:account] : {}
    opportunity_params = params[:opportunity] ? params[:opportunity] : {}
    lead_params = params[:lead] ? params[:lead] : {}
    Rails.logger.debug("account_params----------- #{account_params.inspect}")
    Rails.logger.debug("opportunity_params--------- #{opportunity_params.inspect}")
    Rails.logger.debug("lead_params----------------#{lead_params.inspect}")

    account = Account.account_create_for_order(account_params)
    opportunity = Opportunity.create_for_order(account, opportunity_params)
    lead = Lead.create_for_order(lead_params)
    contact = Contact.create_for_order(lead)

    [account, opportunity, contact, lead]
  end


  def full_name(format = nil)
    lead = Lead.find(self.lead_id)
    if format.nil? || format == "before"
      "#{lead.first_name} #{lead.last_name}"
    else
      "#{lead.last_name}, #{lead.first_name}"
    end
  end

end