module Authorize
  module Token
    def payload
      {
        error: 'API key not provided'
      }
    end

    def client_keys
      ENV['CLIENT_TOKEN'].split
    end

    def api_key_to_string
      request.headers['x-api-key'].to_s if request.headers['x-api-key'].present?
    end

    def authenticate_api_key
      true unless client_keys.include? api_key_to_string
    end

    def validate_api_key
      render json: '', status: :unauthorized if authenticate_api_key
    end
  end
end
