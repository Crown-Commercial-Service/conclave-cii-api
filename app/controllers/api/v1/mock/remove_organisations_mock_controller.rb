module Api
  module V1
    module Mock
      class RemoveOrganisationsMockController < ApplicationMockController

        def delete_orginisation
          mock = MockingService::MockApis.new
          organisations = Api::V1::RemoveOrganisationsController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.delete_orginisation
          mock.disable_mock_service

          if scheme_result.blank?
            render json: '', status: :not_found
          else
            render json: scheme_result
          end
        end
      end
    end
  end
end
