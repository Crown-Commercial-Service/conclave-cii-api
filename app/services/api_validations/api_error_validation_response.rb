module ApiValidations
  class ApiErrorValidationResponse
    def initialize(errors_key)
      super()
      @errors_key = errors_key
      call
    end

    def call
      case @errors_key
      when :id, :scheme, :identifier, :organisation, :additional_identifiers, :ccs_org_id
        raise_exception(Common::StatusCodes::BAD_REQUEST)
      when :no_scheme_found, :no_scheme_id_found, :ccs_org_id_not_found
        raise_exception(Common::StatusCodes::NOT_FOUND)
      when :duplicate_id
        raise_exception(Common::StatusCodes::DUPLICATE_RESOURCE)
      end
    end

    def raise_exception(code)
      raise ApiValidations::ApiError, code
    end
  end
end
