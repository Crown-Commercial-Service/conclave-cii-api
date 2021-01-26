module Api
  module V1
    class CreateOrganisationsController < ActionController::API
      include Authorize::Token
      before_action :validate_api_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = search_scheme_api

        primary_organisation if result.present?
        additional_identifiers if result[:additionalIdentifiers].any?
        if result.blank?
          render json: [], status: :not_found
        else
          render json: [{ "ccs_org_id": @ccs_org_id }], status: :created
        end
      end

      private

      def primary_organisation
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = @api_result[:identifier][:scheme]
        organisation.scheme_org_reg_number = @api_result[:identifier][:id]
        organisation.ccs_org_id = Common::GenerateId.ccs_org_id
        organisation.primary_scheme = true
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def add_additional_identifier(additional_identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = additional_identifier[:scheme]
        organisation.scheme_org_reg_number = additional_identifier[:id]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.save
        organisation.ccs_org_id
      end

      def additional_identifiers
        identifier_ids = search_addional_identifiers
        @api_result[:additionalIdentifiers].each do |user_params|
          add_additional_identifier(user_params) if identifier_ids.include? user_params[:id]
        end
      end

      def validate_params
        validate = ApiValidations::CreateOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
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
    end
  end
end