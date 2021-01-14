module Api
  module V1
    class CreateOrganisationsController < ActionController::API
      include Authorize::Token
      before_action :validate_api_key
      before_action :validate_params

      attr_accessor :ccs_org_id

      def index
        scheme_result = primary_organisation
        additional_organisation
        if scheme_result.blank?
          render json: [], status: :not_found
        else
          render json: [{ "ccs_org_id": scheme_result }], status: :created
        end
      end

      private

      def primary_organisation
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = params[:identifier][:scheme]
        organisation.scheme_org_reg_number = params[:identifier][:id]
        organisation.ccs_org_id = Common::GenerateId.ccs_org_id
        organisation.primary_scheme = true
        organisation.save
        @ccs_org_id = organisation.ccs_org_id
      end

      def add_additional_organisation(additional_identifier)
        organisation = OrganisationSchemeIdentifier.new
        organisation.scheme_code = additional_identifier[:scheme]
        organisation.scheme_org_reg_number = additional_identifier[:id]
        organisation.ccs_org_id = @ccs_org_id
        organisation.primary_scheme = false
        organisation.save
        organisation.ccs_org_id
      end

      def additional_organisation
        params['additional_identifiers'].each do |user_params|
          add_additional_organisation(user_params)
        end
      end

      def validate_params
        validate = ApiValidations::CreateOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end
    end
  end
end
