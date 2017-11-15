namespace :quickbooks do
  desc "Refresh QuickBooks Tokens"
  task :renew_oauth2_tokens => :environment do
    if (qbo_accounts = Quickbook.where('reconnect_token_at <= NOW() AND token_expires_at >= NOW()')).empty?
      p "OAUTH2_RENEW_TOKEN: nothing to do"
    else
      qbo_accounts.each do |q|
        begin
          client = oauth2_client
          client.refresh_token = q.refresh_token
          if resp = client.access_token!
            duration_attrs = { reconnect_token_at: 1.hour.from_now,
                               token_expires_at: 50.minutes.from_now }
            attrs = { access_token: resp.access_token, refresh_token: resp.refresh_token }.merge(duration_attrs)
            if q.update(attrs)
              p "SUCCESS_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id}"
            else
              p  "FAILED_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id} error_message: #{resp}"
            end
          end
        rescue => e
          p "FAILED_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id} error_message: #{e.message}"
        end
      end
    end
  end
  def oauth2_client
    Rack::OAuth2::Client.new(
        identifier: "Q0Tfk6a4VauRIHi4bJhuoxVUYWqBP4zUNSyTPG01b3eocLQuUe",
        secret: "3AZKvrtIrg8Pgq6Hmx2k7FIIL4x78ihy5dEXPPgy",
        redirect_uri: 'http://localhost:3000/admin/settings/oauth2_redirect',
        authorization_endpoint: "https://appcenter.intuit.com/connect/oauth2",
        token_endpoint: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
    )
  end
end
