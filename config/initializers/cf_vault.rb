def config_vault
  Vault.configure do |config|
    config.address = ENV['VAULT_ADDR']
    config.token = ENV['VAULT_TOKEN']
    config.ssl_verify = false # only false until live is setup
  end
  set_env
end

def set_env
  env_vars = Vault.logical.read("#{ENV['VAULT_ENGINE']}/#{ENV['SERVER_ENV_NAME']}")
  env_vars.data.each do |env_key, env_value|
    ENV[env_key.to_s] = env_value.to_s
  end
end

config_vault if ENV['SERVER_ENV_NAME'].present?