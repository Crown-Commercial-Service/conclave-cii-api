module Api
  module V1
    class UpdateOrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = search_scheme_api

        update_organisation if result.present?

        if result.blank?
          render json: '', status: :not_found
        else
          render json: [{ ccs_org_id: @ccs_org_id }], status: :created
        end
      end

      private

      def update_organisation
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = @api_result[:identifier][:scheme]
        organisation.scheme_org_reg_number = @api_result[:identifier][:id]
        organisation.ccs_org_id = params[:ccs_org_id]
        organisation.primary_scheme = false
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def validate_params
        validate = ApiValidations::UpdateOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end

      def search_scheme_api
        @api_result = api_search_result
      end

      def api_search_result
        search_api_with_params = SearchApi.new(params[:identifier][:id], params[:identifier][:scheme])
        search_api_with_params.call
      end
    end
  end
end
