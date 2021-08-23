module Api
  module V1
    class BuyerRegistrationController < ActionController::API
      include Authorize::IntegrationToken
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integration_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :salesforce_result, :api_result, :sales_force_organisation_created

      def create_buyer(mock_req: false)
        create_ccs_org_id
        schemes_list = Common::AdditionalIdentifier.new
        create_from_schemes if schemes_list.schemes.include? params[:account_id_type].to_s
        create_from_salesforce if Common::SalesforceSearchIds.account_id_types_salesforce.include? params[:account_id_type].to_s

        if mock_req
          render_mocking_service
        else
          render_buyers_reg
        end
      end

      # Method to capture some additional mocking service requests, which are missed by not calling any external api's
      def render_mocking_service
        if @duplicate
          render json: '', status: :conflict
        elsif @api_result.blank? && @organisation.blank?
          render json: '', status: :not_found
        else
          render json: build_response, status: :created
        end
      end

      def render_buyers_reg
        if @duplicate
          render json: '', status: :conflict
        elsif @api_result.blank? && @sales_force_organisation_created == false
          render json: '', status: :not_found
        else
          return_success
        end
      end

      def return_success
        render json: build_response, status: :created if @api_result.present?
        render json: [], status: :not_found if @api_result.blank?
      end

      def create_from_salesforce
        salesforce_api_search
        @sales_force_organisation_created = create_organisation if @companies_and_duns_ids.any?
        additional_organisation(@api_result, true) if @api_result.present?
      end

      def create_from_schemes
        @api_result = api_search_result(params[:account_id], params[:account_id_type])
        @api_result = Salesforce::AdditionalIdentifier.new(@api_result).build_response if @api_result.present?
        validate_salesforce
        primary_organisation(@api_result[:identifier]) if @api_result.present? && @api_result[:identifier].present?
        add_additional_identifiers(@api_result[:additionalIdentifiers]) if @api_result.present? && @api_result[:additionalIdentifiers].present?
        @api_result
      end

      def validate_params
        params[:account_id_type] = params[:account_id_type].to_s.delete('-').downcase unless params[:account_id_type].include?('US'.freeze) || params[:account_id_type].include?('GB'.freeze)
        validate = ApiValidations::BuyerRegistration.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def create_ccs_org_id
        @ccs_org_id = Common::GenerateId.ccs_org_id
      end

      def schemes_check(scheme)
        @companies_and_duns_ids.any? { |e| e.include?(scheme) }
      end

      def api_results_check
        @duns_api_results = duns_api_query
        @coh_api_results = coh_api_query

        return false if @coh_api_results.blank? && @duns_api_results.blank?
        return false if @api_result.blank?

        true
      end

      def duns_api_query
        return unless schemes_check('US-DUN'.freeze)

        @companies_and_duns_ids.each do |e| # e = US-DUN-123456 as a valid example.
          @id = e[7..] if e.include?('US-DUN'.freeze) # 123456
          @scheme = e[..5] if e.include?('US-DUN'.freeze) # US-DUN
        end
        api_search_result(@id, @scheme)
      end

      def coh_api_query
        return unless schemes_check('GB-COH'.freeze)

        @companies_and_duns_ids.each do |e| # e = GB-COH-123456 as a valid example.
          @id = e[7..] if e.include?('GB-COH'.freeze) # 123456
          @scheme = e[..5] if e.include?('GB-COH'.freeze) # GB-COH
        end
        api_search_result(@id, @scheme)
      end

      def api_search_result(id, scheme)
        return if id.empty?
        return if id.to_s == 'UNKNOWN'
        return if id.to_s.include? '77777777'

        additional_identifier_search_api_with_params = SearchApi.new(id, scheme)
        additional_identifier_search_api_with_params.call
      end

      def create_organisation
        return false unless api_results_check

        if @coh_api_results.present? && @duns_api_results.present?
          primary_organisation(@coh_api_results[:identifier])
          additional_organisation(@duns_api_results[:identifier], false)
        elsif @coh_api_results.present?
          primary_organisation(@coh_api_results[:identifier])
        elsif @duns_api_results.present?
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
        organisation.hidden = Common::ApiHelper.hide_all_ccs_schemes(identifier[:scheme], hidden)
        # organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save unless @duplicate
      end

      def buyer_exists
        validate = ApiValidations::BuyerExists.new(@api_result)
        render json: validate.errors, status: :conflict unless validate.valid?
      end

      def organisation_exists(org)
        return if @duplicate

        @duplicate = false
        organisation = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: org[:id], scheme_code: org[:scheme])
        @duplicate = true if organisation.present?
      end

      def salesforce_api_search
        search_api_with_params = Salesforce::SalesforceBuyerRegistration.new(params[:account_id], params[:account_id_type])
        @api_result = search_api_with_params.fetch_results
        buyer_exists
        status_code = search_api_with_params.sf_status
        return_error_code(status_code) if status_code > 399
        @companies_and_duns_ids = search_api_with_params.results
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end

      def build_response
        result = Common::MigrationOrganisationResponse.new(@ccs_org_id, hidden: false).response_payload_migration
        result[0][:address] = Common::AddressHelper.new(@api_result).build_response
        result[0][:contactPoint] = Common::ContactHelper.new(@api_result).build_response
        result[0]
      end

      def validate_additional_schemes(schmes)
        validate = ApiValidations::Scheme.new(schmes)
        render json: validate.errors, status: :conflict unless validate.valid?
      end

      def validate_salesforce
        @api_result[:additionalIdentifiers].each do |user_params|
          validate_additional_schemes(user_params) if user_params[:scheme] == Common::AdditionalIdentifier::SCHEME_CCS
        end
      end
    end
  end
end
