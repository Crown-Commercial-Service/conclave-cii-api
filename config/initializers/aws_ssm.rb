require 'aws-sdk-ssm'
require 'rollbar'

private

def config_aws
	params_list = []
	ssm_client = nil
	vcap_services = JSON.parse(ENV['VCAP_SERVICES'])

	vcap_services['user-provided'].each do |user_service|
		params_list = user_service['credentials']['VARS_LIST'] if user_service['credentials']['VARS_LIST'].present?
		if user_service['credentials']['aws_access_key_id'].present?
			ssm_client = Aws::SSM::Client.new(
				region: user_service['credentials']['region'],
				access_key_id: user_service['credentials']['aws_access_key_id'],
				secret_access_key: user_service['credentials']['aws_secret_access_key']
			)
		end
	end
	set_env(ssm_client, params_list) if ssm_client && params_list.any?
end

def set_env(ssm_client, params_list)
	params_list.each do |param_name|
		ENV[param_name] = ssm_client.get_parameter({ name: "/conclave-cii/#{param_name}", with_decryption: true })[:parameter][:value]
	end
	ENV[param_name] = ssm_client.get_parameter({ name: "/conclave-cii/ROLLBAR_ACCESS_TOKEN", with_decryption: true })[:parameter][:value]
	ENV[param_name] = ssm_client.get_parameter({ name: "/conclave-cii/SERVER_ENV_NAME", with_decryption: true })[:parameter][:value]
	config_rollbar if ENV['ROLLBAR_ACCESS_TOKEN'].present?
end

def config_rollbar
	Rollbar.configure do |config|
		config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
		config.environment = ENV['SERVER_ENV_NAME']
	end
	Rails.logger.info('App Deployed & Rollbar Successfully Configured')
	Rollbar.info('App Deployed & Rollbar Successfully Configured')
  end

config_aws if ENV['SERVER_ENV_NAME'].present?
