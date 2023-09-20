module Authorize
  module User
    def validate_client_id
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:missing_client_id) if decoded_token[0]['aud'].blank?
    end

    def validate_user_access_token
      logger = Rails.logger
      logger.info Common::ApiHelper.bearer_token(request.headers)
      ApiValidations::ApiErrorValidationResponse.new(:missing_access_token) if Common::ApiHelper.bearer_token(request.headers).blank?
    end

    def validate_ccs_org_id
      decoded_token = Common::ApiHelper.decode_token(request.headers)
      ApiValidations::ApiErrorValidationResponse.new(:missing_access_token) if decoded_token.blank?
      ApiValidations::ApiErrorValidationResponse.new(:ccs_org_id_not_matched) unless decoded_token[0]['ciiOrgId'] == params['ccs_org_id']
    end

    def validate_and_decode_token
      decoded_token = Common::ApiHelper.decode_token(request.headers)
      ApiValidations::ApiErrorValidationResponse.new(:missing_access_token) if decoded_token.blank?
      decoded_token
    end

    def validate_organisation_user
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized) unless decoded_token[0]['roles'].include?(ENV['ACCESS_ORGANISATION_ADMIN'])
    end

    def validate_ccs_admin_user
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized) unless decoded_token[0]['roles'].include?(ENV['ACCESS_CCS_ADMIN'])
    end

    def validate_data_migration_user
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized) unless decoded_token[0]['roles'].include?(ENV['ACCESS_DATA_MIGRATION'])
    end

    def validate_service_eligibility_user
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized) unless decoded_token[0]['roles'].include?(ENV['ACCESS_MANAGE_SUBSCRIPTIONS'])
    end

    def validate_data_migration_or_org_admin_user
      decoded_token = validate_and_decode_token
      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized) unless decoded_token[0]['roles'].include?(ENV.fetch('ACCESS_DATA_MIGRATION', nil)) || decoded_token[0]['roles'].include?(ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil))
    end

    def validate_service_eligibility_or_ccs_admin_user
      decoded_token = validate_and_decode_token
      if decoded_token[0]['roles'].include?(ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil)) && decoded_token[0]['roles'].exclude?(ENV.fetch('ACCESS_MANAGE_SUBSCRIPTIONS', nil))
        return validate_ccs_org_id

      elsif decoded_token[0]['roles'].include?(ENV.fetch('ACCESS_MANAGE_SUBSCRIPTIONS', nil))
        return

      end

      ApiValidations::ApiErrorValidationResponse.new(:user_access_unauthorized)
    end

    def access_to_hidden_identifiers
      decoded_token = Common::ApiHelper.decode_token(request.headers)
      return true if decoded_token.present? && decoded_token[0]['roles'].include?(ENV.fetch('ACCESS_MANAGE_SUBSCRIPTIONS', nil))

      false
    end

    def validate_access_token
      decoded_token = validate_and_decode_token
      validate_token = SecurityService::Auth.new(decoded_token[0]['aud'], Common::ApiHelper.bearer_token(request.headers)).sec_api_validate_token
      ApiValidations::ApiErrorValidationResponse.new(:invalid_user_access_token) if validate_token.blank?
    end

    def token_to_string
      request.headers['x-api-key'].to_s if request.headers['x-api-key'].present?
    end

    def validate_integration_token
      integration_token = token_to_string
      return true if ENV['INTEGRATION_TOKEN'] == integration_token

      false
    end

    def validate_delete_token
      delete_token = token_to_string
      return true if ENV['DELETE_TOKEN'] == delete_token

      false
    end

    def validate_api_token
      api_token = token_to_string
      return false if Client.find_by(api_key: api_token.to_s)&.id.blank?

      true
    end
  end
end
