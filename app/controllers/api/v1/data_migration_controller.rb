module Api
  module V1
    class DataMigrationController < ActionController::API
      include Authorize::AuthorizationMethods
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integrating_service_user_or_api_key_or_integration_key
      # This is checking for the dummy org (id: 111111111) in params. must be done first, to stop external api calls.
      before_action :mock_id_check
      before_action :create_ccs_org_id

      attr_accessor :ccs_org_id, :salesforce_result, :api_result, :sales_force_organisation_created

      def validate_params
        validate = ApiValidations::DataMigration.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def create_ccs_org_id
        @ccs_org_id = Common::GenerateId.ccs_org_id
        @duns_scheme = Common::AdditionalIdentifier::SCHEME_DANDB
        @coh_scheme = Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
        @sf_scheme = Common::SalesforceSearchIds::SFID
        params[:account_id_type] = params[:account_id_type].downcase.delete('-')
      end

      def create_org_profile
        schemes_list = Common::AdditionalIdentifier.new
        create_from_schemes if schemes_list.schemes.include? params[:account_id_type].to_s
        create_from_salesforce if Common::SalesforceSearchIds.account_id_types_salesforce.include? params[:account_id_type].to_s

        if @duplicate_ccs_org_id
          render json: { organisationId: @duplicate_ccs_org_id.to_s }, status: :conflict
        elsif @api_result.blank? && @sales_force_organisation_created == false
          render json: '', status: :not_found
        else
          return_success
        end
      end

      def return_success
        return render json: build_response, status: :created if required_identifiers_exist

        render json: '', status: :not_found
      end

      def create_from_salesforce
        salesforce_api_search
        @sales_force_organisation_created = create_organisation if create_org_check
        additional_organisation(@api_result, true) if required_identifiers_exist && !@duplicate_ccs_org_id
      end

      def required_identifiers_exist
        return false if @coh_api_results.blank? && @duns_api_results.blank?
        return false if @api_result.blank?

        true
      end

      def create_from_schemes
        @api_result = api_search_result(params[:account_id], params[:account_id_type])
        return if @api_result.blank?

        @api_result = Salesforce::AdditionalIdentifier.new(@api_result).build_response
        validate_salesforce
        search_saleforce_identifiers
        @sales_force_organisation_created = create_organisation if create_org_check
        primary_organisation(@api_result[:identifier]) if !@sales_force_organisation_created && @api_result[:identifier].present?
        add_additional_identifiers(@api_result[:additionalIdentifiers]) if @api_result[:additionalIdentifiers].present?
      end

      def search_saleforce_identifiers
        salesforce_id = @api_result[:additionalIdentifiers][0][:id].split(/~/, 2).first if @api_result[:additionalIdentifiers].any?
        return unless salesforce_id

        salesforce_api = Salesforce::SalesforceDataMigration.new(salesforce_id, @sf_scheme)
        salesforce_api.fetch_results
        @companies_and_duns_ids = salesforce_api.results
      end

      def create_org_check
        return true if !@duplicate_ccs_org_id && @companies_and_duns_ids&.any?

        false
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
        additional_identifier_search_api_with_params = SearchApi.new(id, scheme, return_organisation_id: true)
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
          company_house_additional
        end
        true
      end

      def company_house_additional
        if @duns_api_results[:additionalIdentifiers].any? && @duns_api_results[:additionalIdentifiers][0][:scheme] == @coh_scheme
          primary_organisation(@duns_api_results[:additionalIdentifiers][0])
          add_additional_identifiers([@duns_api_results[:identifier]])
        else
          primary_organisation(@duns_api_results[:identifier])
          add_additional_identifiers(@duns_api_results[:additionalIdentifiers])
        end
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
        organisation.save unless @duplicate_ccs_org_id
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
        organisation.save unless @duplicate_ccs_org_id
      end

      def org_profile_exists
        validate = ApiValidations::OrgProfileExists.new(@api_result)
        @duplicate_ccs_org_id = validate.ccs_organisation_exists
      end

      def organisation_exists(org)
        return if @duplicate_ccs_org_id

        organisation = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: org[:id], scheme_code: org[:scheme])
        @duplicate_ccs_org_id = organisation['ccs_org_id'] if organisation.present?
      end

      def salesforce_api_search
        search_api_with_params = Salesforce::SalesforceDataMigration.new(params[:account_id], params[:account_id_type])
        @api_result = search_api_with_params.fetch_results
        org_profile_exists
        @companies_and_duns_ids = search_api_with_params.results unless @duplicate_ccs_org_id
      end

      def return_error_code(code)
        if code.to_s == '409'
          render json: { organisationId: find_ccs_org_id }, status: code.to_s
        elsif code.to_s.length > 3
          render json: { organisationId: code }, status: '409'.freeze
        else
          render json: '', status: code.to_s
        end
      end

      def find_ccs_org_id
        return @validate_duplicate.data_migration_duplicate_id if @validate_duplicate

        id = Common::ApiHelper.filter_charity_number(params[:account_id], params[:account_id_type])
        scheme_identifier = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: Common::ApiHelper.remove_white_space_from_id(id).to_s)
        scheme_identifier[:ccs_org_id] if scheme_identifier
      end

      def build_response
        result = Common::MigrationOrganisationResponse.new(@ccs_org_id, hidden: false).response_payload_migration
        api_result = api_results(result)
        result[0][:address] = Common::AddressHelper.new(api_result).build_response
        result[0][:contactPoint] = Common::ContactHelper.new(api_result).build_response
        result[0]
      end

      def api_results(result)
        if @coh_api_results
          @coh_api_results
        elsif result[0][:identifier][:scheme] == @coh_scheme
          SearchApi.new(result[0][:identifier][:id], result[0][:identifier][:scheme], address_lookup: true).call
        elsif result[0][:additionalIdentifiers][0][:scheme] == @coh_scheme
          SearchApi.new(result[0][:additionalIdentifiers][:id], result[0][:additionalIdentifiers][:scheme], address_lookup: true).call
        else
          @duns_api_results
        end
      end

      def validate_additional_schemes(schemes)
        @validate_duplicate = ApiValidations::Scheme.new(schemes)
        render json: @validate_duplicate.errors, status: :conflict unless @validate_duplicate.valid?
      end

      def validate_salesforce
        @api_result[:additionalIdentifiers].each do |user_params|
          validate_additional_schemes(user_params) if user_params[:scheme] == Common::AdditionalIdentifier::SCHEME_CCS
        end
      end
    end
  end
end
