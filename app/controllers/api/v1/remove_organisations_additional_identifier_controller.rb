module Api
  module V1
    class RemoveOrganisationsAdditionalIdentifierController < ActionController::API
      include Authorize::Token
      include Authorize::AuthorizationMethods
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_user
      before_action :validate_params

      def delete_additional_identifier
        # While PPON is being developed, we want any related CII functionality to be inaccessible temporarily.
        return render json: '', status: :method_not_allowed if params[:scheme].upcase == Common::AdditionalIdentifier::SCHEME_PPON

        delete_organisation
        render json: '', status: :ok
      rescue StandardError
        render json: '', status: :not_found
      end

      def validate_params
        validate = ApiValidations::RemoveOrganisationAdditionalIdentifier.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def find_organisation
        OrganisationSchemeIdentifier.find_by(ccs_org_id: params[:ccs_org_id].to_s,
                                             scheme_org_reg_number: params[:id].to_s,
                                             scheme_code: params[:scheme].to_s,
                                             primary_scheme: false)
      end

      def primary_org_check
        result = Common::RegisteredOrganisationResponse.new(params[:ccs_org_id].to_s).response_payload
        return false if result.blank?

        result_scheme = result[0][:identifier][:scheme].to_s
        result_id = result[0][:identifier][:id].to_s
        return true if result_scheme == params[:scheme].to_s && result_id == params[:id].to_s

        false
      end

      private

      def delete_organisation
        OrganisationSchemeIdentifier.find_by(ccs_org_id: params[:ccs_org_id].to_s,
                                             scheme_org_reg_number: params[:id].to_s,
                                             scheme_code: params[:scheme].to_s,
                                             primary_scheme: false).destroy
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
