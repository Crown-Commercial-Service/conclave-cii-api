module Api
  module V1
    class UpdateOrganisationsController < ActionController::API
      include Authorize::AuthorizationMethods
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_ccs_org_user_or_api_key
      # This is checking for the dummy org (id: 111111111) in params. must be done first, to stop external api call.
      before_action :mock_id_check
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = set_results
        if result.blank?
          render json: '', status: :not_found
        else
          # If mock id is used, then @ccs_org_id will be empty, and id will contained in 'result' variable instead.
          render json: { organisationId: @ccs_org_id || result }, status: :ok
        end
      end

      def set_results
        if @is_mock_id
          result = Common::ApiHelper.update_dummy_org(params[:ccs_org_id], params[:scheme])
        else
          result = search_scheme_api
          return if result.blank?

          Common::SalesforceHelper.new(result, params[:ccs_org_id]).insert_salesforce_record
          save_or_update_organisation_scheme
        end
        result
      end

      def validate_params
        validate = ApiValidations::UpdateOrganisation.new(params)
        return render json: validate.errors, status: :bad_request unless validate.valid?

        return unless params[:scheme].to_s.upcase == Common::AdditionalIdentifier::SCHEME_PPON

        ppon_pattern = /^[A-Z]{2}\d{4}[A-Z]{2}\d$/.freeze
        render json: '', status: :bad_request unless check_ppon_identifier(params[:ccs_org_id]) && ppon_pattern.match?(params[:id].to_s)
      end

      def check_ppon_identifier(ccs_org_id)
        result = Common::RegisteredOrganisationResponse.new(ccs_org_id, hidden: false).response_payload

        result[0][:additionalIdentifiers]&.none? do |identifier|
          identifier[:scheme].to_s.upcase == Common::AdditionalIdentifier::SCHEME_PPON
        end
      end

      # This is checking for the dummy org (id: 111111111) in params. Sets global variable to true or false, for the rest of controller behavoir.
      def mock_id_check
        @is_mock_id = Common::ApiHelper.find_mock_organisation(params[:scheme], params[:id]) if params.present?
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
        organisation[:hidden] = false
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
        organisation[:hidden] = false
        # organisation[:client_id] = Common::ApiHelper.find_client(api_key_to_string)
        organisation.save
        @ccs_org_id = organisation.present? ? params[:ccs_org_id] : nil
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end

      def search_scheme_api
        @api_result = api_search_result
      end

      def api_search_result
        search_api_with_params = SearchApi.new(params[:id], params[:scheme], params[:ccs_org_id])
        search_api_with_params.call
      end
    end
  end
end
