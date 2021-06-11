module Api
  module V1
    class BuyerRegistrationController < ActionController::API
      include Authorize::IntegrationToken
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integration_key
      before_action :validate_params
      before_action :create_ccs_org_id

      attr_accessor :ccs_org_id, :salesforce_result

      def create_buyer
        salesforce_api_search

        coh_scheme_check if @companies_and_or_duns_ids.any?

        additional_organisation(@salesforce_api_result) if @salesforce_api_result.present?

        if @salesforce_api_result.blank? || @companies_and_or_duns_ids.blank?
          render json: '', status: :not_found
        else
          render json: { ccs_org_id: @ccs_org_id }
        end
      end

      def validate_params
        validate = ApiValidations::BuyerRegistration.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def create_ccs_org_id
        @ccs_org_id = Common::GenerateId.ccs_org_id
      end

      def coh_scheme_check
        duns_api_results = api_search_result(@companies_and_or_duns_ids[0], Common::AdditionalIdentifier::SCHEME_DANDB)

        if @companies_and_or_duns_ids.length == 2
          coh_api_results = api_search_result(@companies_and_or_duns_ids[1], Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE)
          primary_organisation(coh_api_results[:identfier])
          additional_organisation(duns_api_results[:identifier], false)
        else
          primary_organisation(duns_api_results[:identifier])
          add_additional_identifiers(duns_api_results[:additionalIdentifiers])
        end
      end

      def primary_organisation(identfier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identfier[:scheme]
        organisation.scheme_org_reg_number = identfier[:id]
        organisation.uri = identfier[:uri]
        organisation.legal_name = identfier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = true
        organisation.hidden = false
        organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
      end

      def add_additional_identifiers(additional_identifiers)
        additional_identifiers.each do |identfier|
          additional_organisation(identfier, false)
        end
      end

      def api_search_result(id, scheme)
        additional_identifier_search_api_with_params = SearchApi.new(id, scheme)
        additional_identifier_search_api_with_params.call
      end

      def additional_organisation(identfier, hidden)
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
        validate = ApiValidations::BuyerExists.new(@salesforce_api_result)
        render json: validate.errors, status: :method_not_allowed unless validate.valid?
      end

      def salesforce_api_search
        search_api_with_params = Salesforce::SalesforceBuyerRegistration.new(params[:account_id], params[:account_id_type])
        @salesforce_api_result = search_api_with_params.fetch_results
        @companies_and_or_duns_ids = search_api_with_params.results
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
