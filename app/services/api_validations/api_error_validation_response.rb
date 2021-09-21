module ApiValidations
  class ApiErrorValidationResponse
    def initialize(errors_key, ccs_org_id = nil)
      super()
      @errors_key = errors_key
      @ccs_org_id = ccs_org_id
      call
    end

    def call
      Rails.logger.info @errors_key
      case @errors_key
      when :id, :scheme, :identifier, :organisation, :additional_identifiers, :ccs_org_id, :account_id_type_does_not_exist
        raise_exception(Common::StatusCodes::BAD_REQUEST)
      when :no_scheme_found, :no_scheme_id_found, :ccs_org_id_not_found
        raise_exception(Common::StatusCodes::NOT_FOUND)
      when :duplicate_id
        raise_exception(Common::StatusCodes::DUPLICATE_RESOURCE)
      when :missing_access_token, :ccs_org_id_not_matched, :user_access_unauthorized, :missing_client_id, :invalid_user_access_token
        raise_exception(Common::StatusCodes::UNAUTHORIZED)
      end
    end

    def raise_exception(code)
      return raise ApiValidations::ApiError, @ccs_org_id if code == Common::StatusCodes::DUPLICATE_RESOURCE && @ccs_org_id

      raise ApiValidations::ApiError, code
    end
  end
end
