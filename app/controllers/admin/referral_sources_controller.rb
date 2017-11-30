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

  def remove
    logger.debug("in the referral source - destroy")
    referral_source = ReferralSource.find(params[:id])
    referral_source.destroy

    @referral_sources = ReferralSource.all
  end
end