module Api
  module V1
    class RegisteredOrganisationsSchemesController < ActionController::API
      include Authorize::AuthorizationMethods
      # Uncomment this to activate Registry update
      # include RegistryUpdate::UpdateScheme
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_access_users_or_api_key
      before_action :validate_params
      # Uncomment this to activate Registry update
      # before_action :registry_check

      def search_organisation
        params[:ccs_org_id] = search_organisation_by_scheme if @scheme_id

        result = Common::RegisteredOrganisationResponse.new(params[:ccs_org_id], hidden: access_to_hidden_identifiers).response_payload if params[:ccs_org_id]

        if result.present?
          render json: result[0], status: :ok
        else
          render json: '', status: :not_found
        end
      end

      def search_organisation_by_scheme
        scheme = "#{@scheme_id[0]}-#{@scheme_id[1]}".freeze
        id = @scheme_id[2]

        result = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: id, scheme_code: scheme)
        result[:ccs_org_id] if result.present? && result[:ccs_org_id].present? && !result['hidden']
      end

      def validate_params
        return validate_scheme if params[:ccs_org_id].include? '-'

        validate_organisation_id
      end

      def validate_scheme
        @scheme_id = params[:ccs_org_id].strip.split('-')
        validate = Common::AdditionalIdentifier.new.schemes.include? "#{@scheme_id[0]}-#{@scheme_id[1]}"
        render json: '', status: :bad_request unless validate
      end

      def validate_organisation_id
        validate = ApiValidations::ManageRegisteredOrganisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      private

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
