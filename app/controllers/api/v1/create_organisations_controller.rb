module Api
  module V1
    class CreateOrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = search_scheme_api
        generate_record(result)
        render_results(result)
      end

      def generate_record(result)
        # While PPON is being developed, we want any related CII functionality to be inaccessible temporarily.
        return if result.blank? || params[:identifier][:scheme].upcase == Common::AdditionalIdentifier::SCHEME_PPON

        result = salesforce_additional_identifier(@api_result)
        validate_salesforce if defined?(@api_result[:additionalIdentifiers])
        primary_organisation
        additional_identifiers if defined?(result[:additionalIdentifiers])
      end

      def render_results(result)
        # While PPON is being developed, we want any related CII functionality to be inaccessible temporarily.
        if result.blank? || params[:identifier][:scheme].upcase == Common::AdditionalIdentifier::SCHEME_PPON
          render json: '', status: :not_found
        else
          render json: { organisationId: @ccs_org_id }, status: :created
        end
      end

      def primary_organisation
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = @api_result[:identifier][:scheme]
        organisation.scheme_org_reg_number = @api_result[:identifier][:id]
        organisation.uri = @api_result[:identifier][:uri]
        organisation.legal_name = @api_result[:identifier][:legalName]
        organisation.ccs_org_id = Common::GenerateId.ccs_org_id
        organisation.primary_scheme = true
        organisation.hidden = false
        organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def add_additional_identifier(additional_identifier, status)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = additional_identifier[:scheme]
        organisation.scheme_org_reg_number = additional_identifier[:id]
        organisation.uri = additional_identifier[:uri]
        organisation.legal_name = additional_identifier[:legalName]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.hidden = Common::ApiHelper.hide_all_ccs_schemes(additional_identifier[:scheme], status)
        organisation.client_id = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
        organisation.ccs_org_id
      end

      def additional_identifiers
        identifier_ids = params[:additional_identifiers].present? ? search_addional_identifiers : []
        @api_result[:additionalIdentifiers].each do |user_params|
          if identifier_ids.include? user_params[:id]
            add_additional_identifier(user_params, false)
          else
            add_additional_identifier(user_params, true)
          end
        end
      end

      def validate_params
        validate = ApiValidations::CreateOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def return_error_code(code)
        if code.to_s.length > 3
          render json: { organisationId: code }, status: '409'.freeze
        else
          render json: '', status: code.to_s
        end
      end

      def search_addional_identifiers
        identifier_ids = []
        params[:additional_identifiers].each do |user_params|
          identifier_ids.push(user_params[:id])
        end
        identifier_ids
      end

      def search_scheme_api
        @api_result = api_search_result
      end

      def api_search_result
        search_api_with_params = SearchApi.new(params[:identifier][:id], params[:identifier][:scheme])
        search_api_with_params.call
      end

      def salesforce_additional_identifier(result)
        Salesforce::AdditionalIdentifier.new(result).build_response
      end

      def validate_additional_schemes(schmes)
        validate = ApiValidations::Scheme.new(schmes, return_organisation_id: true)
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
