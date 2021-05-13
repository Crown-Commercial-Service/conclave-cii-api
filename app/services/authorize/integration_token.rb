module Authorize
  module IntegrationToken
    include Authorize::Token

    def authenticate_integration_key
      true unless ENV['INTEGRATION_TOKEN'] == api_key_to_string
    end

    def validate_integration_key
      render json: '', status: :unauthorized if authenticate_integration_key
    end
  end
end
