# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::SettingsController < Admin::ApplicationController
  before_action "set_current_tab('admin/settings')", only: [:index]

# GET /admin/settings
# GET /admin/settings.xml
#----------------------------------------------------------------------------
  def index
    session[:state] = SecureRandom.uuid
  end

  def oauth2_redirect
    logger.debug("oauth2_redirect");
    state = params[:state]
    error = params[:error]
    code = params[:code]

    if state == session[:state]
      QB_OAUTH2_CLIENT.authorization_code = code

      if resp = QB_OAUTH2_CLIENT.access_token!
        session[:refresh_token] = resp.refresh_token
        session[:access_token] = resp.access_token
        session[:realm_id] = params[:realmId]

        if Quickbook.first.present?
          q = Quickbook.find(1)
        else
          q = Quickbook.new
        end
        q.realmId=params[:realmId]
        q.refresh_token = resp.refresh_token
        q.access_token = resp.access_token
        q.save
      end
    end
    redirect_to "/admin/settings"
  end

end