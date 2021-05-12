require 'rollbar'

def config_vault
  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  key_store_path = ''
  Vault.configure do |config|
    vcap_services['hashicorp-vault'].each do |key, value|
      key_store_path = "#{key['credentials']['backends_shared']['space']}/#{ENV['SERVER_ENV_NAME']}"
      config.address = key['credentials']['address']
      config.token = key['credentials']['auth']['token']
    end
    config.ssl_verify = true
  end
  set_env(key_store_path)
 end

def set_env(storage_path)
  env_vars = Vault.logical.read(storage_path)
  env_vars.data.each do |env_key, env_value|
    ENV[env_key.to_s] = env_value.to_s
  end
  config_rollbar
end

def config_rollbar
  Rollbar.configure do |config|
    ['sandbox'].each do |env|
      config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
      config.environment = env
    end
  end
  Rails.logger.info('App Deployed & Rollbar Successfully Configured')
  Rollbar.info('App Deployed & Rollbar Successfully Configured')
end

config_vault if ENV['SERVER_ENV_NAME'].present?
