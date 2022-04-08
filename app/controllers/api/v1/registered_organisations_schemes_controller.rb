module Api
  module V1
    class RegisteredOrganisationsSchemesController < ActionController::API
      include Authorize::User
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_ccs_org_user_or_api_key
      before_action :validate_params

      def search_organisation(organisation_id = nil)
        params[:ccs_org_id] = organisation_id if organisation_id

        result = Common::RegisteredOrganisationResponse.new(params[:ccs_org_id], hidden: false).response_payload
        if result.present?
          render json: build_response(result), status: :ok
        else
          render json: '', status: :not_found
        end
      end

      def search_organisation_by_scheme
        result = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: params[:id], scheme_code: params[:scheme])
        return render json: '', status: :not_found unless result.present? && result[:ccs_org_id].present?

        search_organisation(result[:ccs_org_id])
      end

      def build_response(result)
        api_result = SearchApi.new(result[0][:identifier][:id], result[0][:identifier][:scheme], address_lookup: true).call
        result[0][:address] = Common::AddressHelper.new(api_result).build_response
        result[0]
      end

      def validate_params
        if params[:ccs_org_id].present?
          return_error_code('bad_request') unless validate_organisation_id.valid?
        else
          return_error_code('bad_request') unless validate_scheme
        end
      end

      def validate_organisation_id
        ApiValidations::ManageRegisteredOrganisation.new(params)
      end

      def validate_scheme
        return Common::AdditionalIdentifier.new.schemes.include? params[:scheme].to_s if params[:scheme].to_s

        false
      end

      private

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
