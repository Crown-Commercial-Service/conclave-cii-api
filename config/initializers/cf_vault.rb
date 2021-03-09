def config_vault
  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  key_store_path = ''
  vault_engine = 'cubbyhole'
  Vault.configure do |config|
    vcap_services['hashicorp-vault'].each do |key, value|
      key_store_path = "#{vault_engine}/#{ENV['SERVER_ENV_NAME']}"
      config.address = 'https://dev.vault.ai-cloud.uk:8443/'
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
end

config_vault if ENV['SERVER_ENV_NAME'].present?