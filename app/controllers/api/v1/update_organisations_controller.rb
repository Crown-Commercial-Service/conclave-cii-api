module Api
  module V1
    class UpdateOrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = search_scheme_api

        save_or_update_organisation_scheme if result.present?

        if result.blank?
          render json: '', status: :not_found
        else
          render json: [{ ccs_org_id: @ccs_org_id }], status: :ok
        end
      end

      private

      def save_or_update_organisation_scheme
        organisation = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: @api_result[:identifier][:id], scheme_code: @api_result[:identifier][:scheme])
        update_organisation(organisation) if organisation.present?
        create_organisation if organisation.blank?
      end

      def update_organisation(organisation)
        organisation[:scheme_code] = @api_result[:identifier][:scheme]
        organisation[:scheme_org_reg_number] = @api_result[:identifier][:id]
        organisation[:ccs_org_id] = params[:ccs_org_id]
        organisation[:uri] = @api_result[:identifier][:uri]
        organisation[:legal_name] = @api_result[:identifier][:legalName]
        organisation[:primary_scheme] = organisation[:primary_scheme]
        organisation[:active] = true
        organisation.save
        @ccs_org_id = organisation.present? ? params[:ccs_org_id] : nil
      end

      def create_organisation
        organisation = OrganisationSchemeIdentifier.new
        organisation[:scheme_code] = @api_result[:identifier][:scheme]
        organisation[:scheme_org_reg_number] = @api_result[:identifier][:id]
        organisation[:ccs_org_id] = params[:ccs_org_id]
        organisation[:uri] = @api_result[:identifier][:uri]
        organisation[:legal_name] = @api_result[:identifier][:legalName]
        organisation[:primary_scheme] = false
        organisation[:active] = true
        organisation.save
        @ccs_org_id = organisation.present? ? params[:ccs_org_id] : nil
      end

      def validate_params
        validate = ApiValidations::UpdateOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end

      def search_scheme_api
        @api_result = api_search_result
      end

      def api_search_result
        search_api_with_params = SearchApi.new(params[:identifier][:id], params[:identifier][:scheme], params[:ccs_org_id])
        search_api_with_params.call
      end
    end
  end
end
