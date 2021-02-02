require 'rollbar'

def config_rollbar
    vcap_services = JSON.parse(ENV['VCAP_SERVICES'])

    Rollbar.configure do |config|
        vcap_services['user-provided'].each do |key, value|
            if key['name'].to_s == 'rollbar'
            config.access_token = key['credentials']['ROLLBAR_ACCESS_TOKEN']
            config.environment = key['credentials']['ROLLBAR_ENVIRONMENT']
            end
        end
    end
end

config_rollbar if ENV['SERVER_ENV_NAME'].present?

Rollbar.error('Hello world') # Testing the rollbar integration works - remove after.