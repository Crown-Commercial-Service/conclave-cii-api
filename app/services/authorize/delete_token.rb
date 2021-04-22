module Authorize
  module DeleteToken
    include Authorize::Token

    def authenticate_key
      true unless ENV['DELETE_TOKEN'] == api_key_to_string
    end

    def validate_key
      render json: '', status: :unauthorized if authenticate_key
    end
  end
end
