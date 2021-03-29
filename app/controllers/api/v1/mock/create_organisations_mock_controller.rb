module Api
  module V1
    module Mock
      class CreateOrganisationsMockController < ApplicationMockController

        def index
          mock = MockingService::MockApis.new
          organisations = Api::V1::CreateOrganisationsController.new
          organisations.request = request
          organisations.response = response
          organisations.validate_params
          scheme_result = organisations.index

          if scheme_result.blank?
            render json: '', status: :not_found
          else
            mock.disable_mock_service
            render json: scheme_result
          end
        end
      end
    end
  end
end
