class Admin::AccountCategoriesController < Admin::ApplicationController
  def new
    @account_category = AccountCategory.new
  end

  def create
    ac = AccountCategory.new
    # account_category"=>{"name"=>"Legal"}
    ac.name = params[:account_category][:name]
    ac.save
    @account_categories = AccountCategory.all
  end

end