module Api
  module V1
    module Mock
      class OrganisationsMockController < ApplicationMockController
        before_action :organisations

        def search_organisation
          run_mock
          result = @mock_controller.search_organisation
          response_result(result)
        end

        def organisations
          @mock_controller = Api::V1::OrganisationsController.new
        end
      end
    end
  end
end
