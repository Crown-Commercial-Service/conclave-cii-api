module Authorize
  module AuthorizationMethods
    include Authorize::User

    def validate_no_role
      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_ccs_org_id
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

    def validate_service_user_or_org_admin_or_api_keys
      return if validate_api_token
      return if validate_integration_token

      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_data_migration_or_org_admin_user
    end

    def validate_ccs_org_user_or_api_key
      return if validate_api_token

      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_organisation_user
      validate_ccs_org_id
    end

    def validate_ccs_admin_or_api_key
      return if validate_api_token

      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_ccs_admin_user
      validate_ccs_org_id
    end

    def validate_access_users_or_api_key
      return if validate_api_token

      validate_client_id
      validate_user_access_token
      validate_access_token
      validate_service_eligibility_or_ccs_admin_user
    end
  end
end
