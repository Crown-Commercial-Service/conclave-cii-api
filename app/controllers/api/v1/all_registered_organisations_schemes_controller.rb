module Api
  module V1
    class AllRegisteredOrganisationsSchemesController < ActionController::API
      include Authorize::AuthorizationMethods
      include RegistryUpdate::UpdateScheme
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_ccs_admin_or_api_key
      before_action :validate_params
      before_action :registry_check

      def search_organisation
        result = Common::RegisteredOrganisationResponse.new(params[:ccs_org_id], hidden: true).response_payload
        if result.present?
          render json: result[0], status: :ok
        else
          render json: '', status: :not_found
        end
      end

      def validate_params
        validate = ApiValidations::ManageRegisteredOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      private

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
