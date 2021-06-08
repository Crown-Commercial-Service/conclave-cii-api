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

        @primary_added = false
        id_results = search_scheme_api
        coh_scheme_check(id_results)
        all_identifiers if defined?(id_results[:additionalIdentifiers])

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
        return if id_results.blank?

        if id_result[:identifier][:scheme] == Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
          add_primary_organisation(id_result[:identifier])
        elsif defined?(id_results[:additionalIdentifiers])
          id_result[:additionalIdentifiers].each do |identifiers|
            add_primary_organisation(identifiers) if identifiers[:scheme] == Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
          end
        end
        add_primary_organisation(id_result[:identifier]) unless @primary_added ###################### work this into conditional****
      end

      def add_primary_organisation(identfier)
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
        @primary_added = true ######################################################################### ****
      end

      def add_additional_identifier(additional_identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = additional_identifier[:scheme]
        organisation.scheme_org_reg_number = additional_identifier[:id]
        organisation.uri = additional_identifier[:uri]
        organisation.legal_name = additional_identifier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.hidden = false
        organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
        organisation.ccs_org_id
      end

      def all_identifiers
        @all_identifier_api_result[:additionalIdentifiers].each do |identfier|
          add_additional_identifier(identfier)
        end
      end

      def search_scheme_api
        @all_identifier_api_result = all_identifier_api_search_result
      end

      def all_identifier_api_search_result
        additional_identifier_search_api_with_params = SearchApi.new(params[:account_id], params[:account_id_type])
        additional_identifier_search_api_with_params.call
      end

      # { ^^^^^^^returns^^^^^^^^^
      #   name: name,
      #   identifier: {CompaniesHouse::Indentifier.new(@result).build_response},
      #   additionalIdentifiers: [{},{},{},...],
      #   address: CompaniesHouse::Address.new(@result).build_response,
      #   contactPoint: CompaniesHouse::Contact.new(@result).build_response
      # }

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

      # { ^^^^^^^returns^^^^^^^^^
      #   scheme: Common::AdditionalIdentifier::SCHEME_CCS,
      #   id: salesforce_scheme_id,
      #   legalName: legal_name,
      #   uri: uri,
      # }

      def api_result
        @api_result = api_search_result
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
