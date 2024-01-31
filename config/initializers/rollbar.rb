require 'rollbar'

private

def config_rollbar
	Rollbar.configure do |config|
	  
		config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
		config.environment = ENV['ROLLBAR_ENVIRONMENT']
	  
	end
	Rails.logger.info('App Deployed & Rollbar Successfully Configured')
	Rollbar.info('App Deployed & Rollbar Successfully Configured')
end

config_rollbar if ENV['ROLLBAR_ACCESS_TOKEN'].present?
