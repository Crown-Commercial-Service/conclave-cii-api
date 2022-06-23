module Authorize
  module Token
    def payload
      {
        error: 'API key not provided'
      }
    end

    def api_key_to_string
      if request.headers['x-api-key-delete'].present?
        request.headers['x-api-key-delete'].to_s
      elsif request.headers['x-api-key'].present?
        request.headers['x-api-key'].to_s
      end
    end

    def client_auth
      Client.find_by(api_key: api_key_to_string.to_s)
    end

    def authenticate_api_key
      true if client_auth&.id.blank?
    end

    def validate_api_key
      render json: '', status: :unauthorized if authenticate_api_key
    end
  end
end
