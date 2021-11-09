module ApiValidations
  class ApiErrorValidationResponse
    def initialize(errors_key, organisationId = nil)
      super()
      @errors_key = errors_key
      @organisationId = organisationId
      call
    end

    def call
      Rails.logger.info @errors_key
      case @errors_key
      when :id, :scheme, :identifier, :organisation, :additional_identifiers, :organisationId, :account_id_type_does_not_exist
        raise_exception(Common::StatusCodes::BAD_REQUEST)
      when :no_scheme_found, :no_scheme_id_found, :organisationId_not_found
        raise_exception(Common::StatusCodes::NOT_FOUND)
      when :duplicate_id
        raise_exception(Common::StatusCodes::DUPLICATE_RESOURCE)
      when :missing_access_token, :organisationId_not_matched, :user_access_unauthorized, :missing_client_id, :invalid_user_access_token
        raise_exception(Common::StatusCodes::UNAUTHORIZED)
      end
    end

    def raise_exception(code)
      return raise ApiValidations::ApiError, @organisationId if code == Common::StatusCodes::DUPLICATE_RESOURCE && @organisationId

      raise ApiValidations::ApiError, code
    end
  end
end
