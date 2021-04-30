module Authorize
  module User
    def validate_client_id
      ApiValidations::ApiErrorValidationResponse.new(:missing_client_id) if params[:clientid].blank?
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

    def validate_access_token
      validate_token = SecurityService::Auth.new(params[:clientid], Common::ApiHelper.bearer_token(request.headers)).sec_api_validate_token
      ApiValidations::ApiErrorValidationResponse.new(:invalid_user_access_token) if validate_token.blank?
    end

    def validate_user
      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_organisation_user
      validate_ccs_org_id
    end

    def validate_ccs_admin
      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_ccs_admin_user
      validate_ccs_org_id
    end
  end
end
