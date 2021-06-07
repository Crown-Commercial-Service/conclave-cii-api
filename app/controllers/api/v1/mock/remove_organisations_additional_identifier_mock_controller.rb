module Api
  module V1
    module Mock
      class RemoveOrganisationsAdditionalIdentifierMockController < ActionController::API
        #include Authorize::Token
        #include Authorize::User
        rescue_from ApiValidations::ApiError, with: :return_error_code
        #before_action :validate_api_key
        #before_action :validate_user
        #before_action :validate_params

        def delete_additional_identifier
          delete_organisation
          render json: '', status: :ok
        rescue StandardError
          render json: '', status: :bad_request
        end

        def validate_params
          validate = ApiValidations::RemoveOrganisationAdditionalIdentifier.new(params)
          render json: validate.errors, status: :bad_request unless validate.valid?
        end

        private

        def delete_organisation
          OrganisationSchemeIdentifier.find_by(ccs_org_id: params[:ccs_org_id].to_s,
                                              scheme_org_reg_number: params[:identifier][:id].to_s,
                                              scheme_code: params[:identifier][:scheme].to_s,
                                              primary_scheme: false).destroy
        end

        def return_error_code(code)
          render json: '', status: code.to_s
        end
      end
    end
  end
end
