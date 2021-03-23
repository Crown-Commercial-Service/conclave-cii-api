module Api
  module V1
    module Mock
      class RemoveOrganisationsAditionalIdentifierMockController < RemoveOrganisationsAditionalIdentifierController
        include Authorize::Token
        include WebMock::API
        rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
        rescue_from ApiValidations::ApiError, with: :return_error_code
        before_action :validate_api_key

        def delete_addtional_identifier
          mock = MockingService::MockApis.new
          organisations = Api::V1::RemoveOrganisationsAditionalIdentifierController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.delete_addtional_identifier
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