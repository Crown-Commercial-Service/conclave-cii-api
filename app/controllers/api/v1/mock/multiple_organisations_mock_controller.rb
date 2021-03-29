module Api
  module V1
    module Mock
      class MultipleOrganisationsMockController < ApplicationMockController

        def search_organisation
          mock = MockingService::MockApis.new
          organisations = Api::V1::MultipleOrganisationsController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.search_organisation
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
