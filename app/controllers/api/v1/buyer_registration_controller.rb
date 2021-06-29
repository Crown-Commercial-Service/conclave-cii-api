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

        organisation = create_organisation if @companies_and_duns_ids.any?

        additional_organisation(@salesforce_api_result, true) if @salesforce_api_result.present?

        if @duplicate
          render json: '', status: :method_not_allowed
        elsif @salesforce_api_result.blank? && organisation.blank?
          render json: '', status: :not_found
        else
          render json: [{ ccs_org_id: @ccs_org_id }], status: :created
        end
      end

      def validate_params
        validate = ApiValidations::BuyerRegistration.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def create_ccs_org_id
        @ccs_org_id = Common::GenerateId.ccs_org_id
        @duns_scheme = Common::AdditionalIdentifier::SCHEME_DANDB
        @coh_scheme = Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
      end

      def schemes_check(scheme)
        @companies_and_duns_ids.any? { |e| e.include?(scheme) }
      end

      def api_results_check
        @duns_api_results = duns_api_query
        @coh_api_results = coh_api_query

        return false if @coh_api_results.blank? && @duns_api_results.blank?
        return false if @salesforce_api_result.blank?

        true
      end

      def duns_api_query
        return unless schemes_check(@duns_scheme)

        @companies_and_duns_ids.each do |e| # e = US-DUN-123456 as a valid example.
          @id = e[7..] if e.include?(@duns_scheme) # 123456
          @scheme = e[..5] if e.include?(@duns_scheme) # US-DUN
        end
        api_search_result(@id, @scheme)
      end

      def coh_api_query
        return unless schemes_check(@coh_scheme)

        @companies_and_duns_ids.each do |e| # e = GB-COH-123456 as a valid example.
          @id = e[7..] if e.include?(@coh_scheme) # 123456
          @scheme = e[..5] if e.include?(@coh_scheme) # GB-COH
        end
        api_search_result(@id, @scheme)
      end

      def api_search_result(id, scheme)
        additional_identifier_search_api_with_params = SearchApi.new(id, scheme)
        additional_identifier_search_api_with_params.call
      end

      def create_organisation
        return false unless api_results_check

        if @companies_and_duns_ids.length == 2
          primary_organisation(@coh_api_results[:identifier])
          additional_organisation(@duns_api_results[:identifier], false)
        elsif @companies_and_duns_ids.length == 1 && schemes_check(@coh_scheme)
          primary_organisation(@coh_api_results[:identifier])
        elsif @companies_and_duns_ids.length == 1 && schemes_check(@duns_scheme)
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
        organisation_exists(identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identifier[:scheme]
        organisation.scheme_org_reg_number = identifier[:id]
        organisation.uri = identifier[:uri]
        organisation.legal_name = identifier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = true
        organisation.hidden = false
        # organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save unless @duplicate
      end

      def additional_organisation(identifier, hidden)
        organisation_exists(identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = identifier[:scheme]
        organisation.scheme_org_reg_number = identifier[:id]
        organisation.uri = identifier[:uri]
        organisation.legal_name = identifier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.hidden = hidden
        # organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save unless @duplicate
      end

      def buyer_exists
        validate = ApiValidations::BuyerExists.new(@salesforce_api_result)
        render json: validate.errors, status: :method_not_allowed unless validate.valid?
      end

      def organisation_exists(org)
        return if @duplicate

        @duplicate = false
        organisation = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: org[:id], scheme_code: org[:scheme])
        @duplicate = true if organisation.present?
      end

      def salesforce_api_search
        search_api_with_params = Salesforce::SalesforceBuyerRegistration.new(params[:account_id], params[:account_id_type])
        @salesforce_api_result = search_api_with_params.fetch_results
        buyer_exists
        @companies_and_duns_ids = search_api_with_params.results
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
