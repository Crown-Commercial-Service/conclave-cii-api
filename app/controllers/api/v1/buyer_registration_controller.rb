module Api
  module V1
    class BuyerRegistrationController < ActionController::API
      include Authorize::IntegrationToken
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integration_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :salesforce_result

      def create_buyer
        id_results = search_scheme_api
        coh_scheme_check(id_results)
        all_identifiers if defined?(id_results[:additionalIdentifiers])

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

      def coh_scheme_check(id_results)
        if defined?(id_results[:additionalIdentifiers])
          id_result[:additionalIdentifiers].each do |identifiers|
            return add_primary_organisation(identifiers) if identifiers[:scheme] == Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
          end
        else
          add_primary_organisation(id_result[:identifier])
        end
      end

      def add_primary_organisation(identfier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identfier[:scheme]
        organisation.scheme_org_reg_number = identfier[:id]
        organisation.uri = identfier[:uri]
        organisation.legal_name = identfier[:legalName]
        organisation.ccs_org_id = Common::GenerateId.ccs_org_id
        organisation.primary_scheme = true
        organisation.hidden = false
        organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def all_identifiers
        @all_identifier_api_result[:additionalIdentifiers].each do |identfier|
          additional_organisation(identfier, false)
        end
      end

      def search_scheme_api
        @all_identifier_api_result = all_identifier_api_search_result
      end

      def all_identifier_api_search_result
        additional_identifier_search_api_with_params = SearchApi.new(params[:account_id], params[:account_id_type])
        additional_identifier_search_api_with_params.call
      end

      def additional_organisation(identfier = @api_result, hidden = true)
        buyer_exists
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identfier[:scheme]
        organisation.scheme_org_reg_number = identfier[:id]
        organisation.uri = identfier[:uri]
        organisation.legal_name = identfier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.hidden = hidden
        organisation.save
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
