module Api
  module V1
    module Mock
      class RegisteredOrganisationsSchemesMockController < RegisteredOrganisationsSchemesController
        include Authorize::Token
        include WebMock::API
        rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
        rescue_from ApiValidations::ApiError, with: :return_error_code
        before_action :validate_api_key

        def search_organisation
          mock = MockingService::MockApis.new
          organisations = Api::V1::RegisteredOrganisationsSchemesController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.search_organisation
          if scheme_result.blank?
            render json: '', status: :not_found
          else
            mock.disable_mock_service
            render json: scheme_result
          end
        end

        def return_error_code_http
          render json: '', status: :not_found
        end

        def return_error_code(code)
          render json: '', status: code.to_s
        end
      end
    end
  end
end
