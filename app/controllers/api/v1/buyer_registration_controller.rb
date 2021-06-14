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

        create_organisation = coh_scheme_check if @companies_and_or_duns_ids.any?

        additional_organisation(@salesforce_api_result, true) if create_organisation # if @salesforce_api_result.present?

        if @salesforce_api_result.blank? || !create_organisation
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

      def duns_api_query
        scheme = Common::AdditionalIdentifier::SCHEME_DANDB
        id = @companies_and_or_duns_ids[0]
        api_search_result(id, scheme) || false
      end

      def coh_api_query
        scheme = Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
        id = @companies_and_or_duns_ids[1]
        api_search_result(id, scheme) || false
      end

      def api_search_result(id, scheme)
        additional_identifier_search_api_with_params = SearchApi.new(id, scheme)
        additional_identifier_search_api_with_params.call
      end

      def api_results_check
        @duns_api_results = duns_api_query
        @coh_api_results = coh_api_query if @companies_and_or_duns_ids.length == 2
        
        if @duns_api_results === false || @coh_api_results === false || !@salesforce_api_result.present?
          false
        else
          true
        end
      end

      def coh_scheme_check
        return false unless api_results_check

        if @companies_and_or_duns_ids.length == 2
          primary_organisation(@coh_api_results[:identifier])
          additional_organisation(@duns_api_results[:identifier], false)
        else
          primary_organisation(@duns_api_results[:identifier])
          add_additional_identifiers(@duns_api_results[:additionalIdentifiers])
        end
        true
      end

      def add_additional_identifiers(additional_identifiers)
        additional_identifiers.each do |identifier|
          additional_organisation(identifier, false)
        end
      end

      def primary_organisation(identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identifier[:scheme]
        organisation.scheme_org_reg_number = identifier[:id]
        organisation.uri = identifier[:uri]
        organisation.legal_name = identifier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = true
        organisation.hidden = false
        # organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
      end

      def additional_organisation(identifier, hidden)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identifier[:scheme]
        organisation.scheme_org_reg_number = identifier[:id]
        organisation.uri = identifier[:uri]
        organisation.legal_name = identifier[:legalName]
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
        buyer_exists
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
