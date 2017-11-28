class Admin::ReferralSourcesController < Admin::ApplicationController
  def new

  end

  def index
    @referral_sources = ReferralSource.all
  end

  def create

    rfs = ReferralSource.new
    rfs.name = params[:referral_source][:name]
    rfs.save
    @referral_sources = ReferralSource.all
  end
end