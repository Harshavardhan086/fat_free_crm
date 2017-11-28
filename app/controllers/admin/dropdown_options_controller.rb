class Admin::DropdownOptionsController < Admin::ApplicationController

  def index
    @referral_sources = ReferralSource.all
    @account_categories = AccountCategory.all
  end

  def new
    @referral_source = ReferralSource.new
    @account_category = AccountCategory.new
  end

  def create

  end

  def edit

  end

  def update

  end

end