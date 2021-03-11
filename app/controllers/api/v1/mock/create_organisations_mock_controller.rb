module Api
  module V1
    module Mock
      class CreateOrganisationsMockController < ActionController::API
        include Authorize::Token
        rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
        rescue_from ApiValidations::ApiError, with: :return_error_code
        before_action :validate_api_key

        def index
          MockingService::MockApis.new
          organisations = Api::V1::CreateOrganisationsController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.index

          if scheme_result.blank?
            render json: '', status: :not_found
          else
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
