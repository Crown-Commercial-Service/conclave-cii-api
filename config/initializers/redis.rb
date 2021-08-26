# frozen_string_literal: true

if ENV['SERVER_ENV_NAME'].present?
    vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
    vcap_services['redis'].each do |key, value|
        if key['credentials'].present?
            ENV['REDIS_URL'] = key['credentials']['uri']
        end
    end
end

