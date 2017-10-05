require 'rack/oauth2'
require 'qbo_api'

QBO_API_CLIENT_ID = "Q0Tfk6a4VauRIHi4bJhuoxVUYWqBP4zUNSyTPG01b3eocLQuUe"
QBO_API_CLIENT_SECRET = "3AZKvrtIrg8Pgq6Hmx2k7FIIL4x78ihy5dEXPPgy"

::QB_OAUTH2_CLIENT = Rack::OAuth2::Client.new({
                                                  :identifier => QBO_API_CLIENT_ID,
                                                  :secret => QBO_API_CLIENT_SECRET,
                                                  :redirect_uri => "http://localhost:3000/admin/settings/oauth2_redirect",
                                                  :authorization_endpoint => "https://appcenter.intuit.com/connect/oauth2",
                                                  :token_endpoint => "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
                                              })


