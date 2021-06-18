module Api
  module V1
    class AllRegisteredOrganisationsSchemesController < ActionController::API
      # include Authorize::Token
      # include Authorize::User
      rescue_from ApiValidations::ApiError, with: :return_error_code
      # before_action :validate_api_key
      # before_action :validate_ccs_admin
      before_action :validate_params

      def search_organisation
        result = Common::RegisteredOrganisationResponse.new(params[:ccs_org_id], hidden: true).response_payload
        if result.present?
          render json: result, status: :ok
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
