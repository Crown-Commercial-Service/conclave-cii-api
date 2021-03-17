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
      if request.headers['x-api-key'].present?
        request.headers['x-api-key'].to_s
      elsif request.headers['Apikey'].present?
        request.headers['Apikey'].to_s
      end
    end

    def authenticate_api_key
      true unless client_keys.include? api_key_to_string
    end

    def validate_api_key
      render json: '', status: :unauthorized if authenticate_api_key
    end
  end
end
