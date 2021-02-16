module Api
  module V1
    class RemoveOrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params

      def delete_orginisation
        delete_all_orginsation_ids
        render json: '', status: :ok
      rescue StandardError
        render json: '', status: :bad_request
      end

      private

      def delete_all_orginsation_ids
        OrganisationSchemeIdentifier.destroy_by(ccs_org_id: params[:ccs_org_id].to_s)
      end

      def validate_params
        validate = ApiValidations::RemoveOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
