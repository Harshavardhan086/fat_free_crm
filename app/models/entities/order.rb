class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :lead
  belongs_to :opportunity
  belongs_to :account
  has_many :contacts
  has_many :order_files
  has_many :emails, as: :mediator
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'

  accepts_nested_attributes_for :order_files, reject_if: :all_blank, allow_destroy: true
  serialize :subscribed_users, Set

  # Show orders which either belong to the user and are unassigned, or are assigned to the user
  scope :visible_on_dashboard, ->(user) {
    where('user_id = :user_id ', user_id: user.id)
  }

  scope :by_created_at, -> { order("created_at DESC") }

  scope :text_search, ->(query) { ransack('state_of_incorporate_cont' => query).result }
  # scope :text_search, ->(query) {
  #   where("account.name", query)
  # }
  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: [ "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w(leads tasks)
  ransack_can_autocomplete

  validates_presence_of :account_id, message: :missing_account
  validates_presence_of :lead_id , message: :missing_lead_details
  validates_presence_of :state_of_incorporate , message: :missing_state_of_incorporate


  def order_attributes(params)
    account_params = params[:account] ? params[:account] : {}
    opportunity_params = params[:opportunity] ? params[:opportunity] : {}
    lead_params = params[:lead] ? params[:lead] : {}
    contact_params = params[:contact] ? params[:contact] : {}
    task_params = params[:task] ? params[:task] : {}
    Rails.logger.debug("account_params----------- #{account_params.inspect}")
    Rails.logger.debug("opportunity_params--------- #{opportunity_params.inspect}")
    Rails.logger.debug("lead_params----------------#{lead_params.inspect}")

    account = Account.account_create_for_order(account_params)
    opportunity = Opportunity.create_for_order(account, opportunity_params, task_params)
    lead = Lead.create_for_order(lead_params)
    Rails.logger.debug("The SAVED LEAD IS ************* #{lead.inspect}")
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

  ActiveSupport.run_load_hooks(:fat_free_crm_order, self)
end