module Api
  module V1
    class DataMigrationController < ActionController::API
      include Authorize::AuthorizationMethods
      include CreateOrganisations
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integrating_service_user
      before_action :create_params
      # This is checking for the dummy org (id: 111111111) in params. must be done first, to stop external api call.
      before_action :mock_id_check
      before_action :validate_params

      attr_accessor :ccs_org_id, :api_result

      def index
        result = search_scheme_api unless @is_mock_id
        generate_record(result)
        # If the dummy org (id: 111111111) has been found, this will add it to db, and return the ccs_org_id to be rendered.
        result = Common::ApiHelper.add_dummy_org(api_key_to_string, params[:scheme], true) if @is_mock_id
        render_results(result)
      end

      def create_params
        if params.present?
          schemes = { 'scheme' => params[:scheme], 'id' => params[:id] }
          params[:identifier] = schemes
          puts 'params'
          puts params
          puts 'params'
        end
      end
    end
  end
end
