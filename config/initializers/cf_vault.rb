def config_vault
  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  key_store_path = ''
  Vault.configure do |config|
    vcap_services['user-provided'].each do |key, value|
      if key['name'].to_s == 'vault-service-broker'
        key_store_path = "#{key['credentials']['vault_engine']}/#{ENV['SERVER_ENV_NAME']}"
        config.address = key['credentials']['vault_addr']
        config.token = key['credentials']['vault_token']
      end
    end

    config.ssl_verify = false # only false until live is setup
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