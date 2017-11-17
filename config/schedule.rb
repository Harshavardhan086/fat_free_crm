# makes Rails.root as well as other environment specific Rails.application.config values available
require File.expand_path(File.dirname(__FILE__) + "/environment")

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "./log/renew_aouth_cron.log"
set :environment, "development"

every 1.minutes do
  Rails.logger.debug( "RENEWING Oauth token")
  runner "Quickbook.renew_oauth2_tokens"
end