module Api
  module V1
    class BuyerRegistrationController < ActionController::API
      include Authorize::IntegrationToken
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integration_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :salesforce_result

      def create_buyer
        scheme_result = api_result
        additional_organisation if scheme_result.present?
        if scheme_result.blank?
          render json: '', status: :not_found
        else
          render json: { ccs_org_id: @ccs_org_id }
        end
      end

      def validate_params
        validate = ApiValidations::BuyerRegistration.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def additional_organisation
        buyer_exists
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = @api_result[:scheme]
        organisation.scheme_org_reg_number = @api_result[:id]
        organisation.uri = @api_result[:uri]
        organisation.legal_name = @api_result[:legalName]
        organisation.ccs_org_id = Common::GenerateId.ccs_org_id
        organisation.primary_scheme = false
        organisation.hidden = true
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def buyer_exists
        validate = ApiValidations::BuyerExists.new(@api_result)
        render json: validate.errors, status: :method_not_allowed unless validate.valid?
      end

      def api_search_result
        search_api_with_params = Salesforce::SalesforceBuyerRegistration.new(params[:account_id], params[:account_id_type])
        search_api_with_params.fetch_results
      end

      def api_result
        @api_result = api_search_result
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
