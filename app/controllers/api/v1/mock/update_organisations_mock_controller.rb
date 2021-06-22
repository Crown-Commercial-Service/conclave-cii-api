module Api
  module V1
    module Mock
      class UpdateOrganisationsMockController < ApplicationMockController
        before_action :update_organisations

        def index
          run_mock
          result = @mock_controller.index
          response_result(result)
        end

        def update_organisations
          @mock_controller = Api::V1::UpdateOrganisationsController.new
        end
      end
    end
  end
end
