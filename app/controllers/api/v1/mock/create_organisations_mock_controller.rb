module Api
  module V1
    module Mock
      class CreateOrganisationsMockController < ApplicationMockController
        before_action :search_controller

        def index
          run_mock
          scheme_result = @mock_controller.index
          response_result(scheme_result)
        end

        def search_controller
          @mock_controller = Api::V1::CreateOrganisationsController.new
        end
      end
    end
  end
end
