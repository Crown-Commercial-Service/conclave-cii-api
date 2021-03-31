module Api
  module V1
    module Mock
      class ManageOrganisationsMockController < ApplicationMockController
        before_action :manage_organisations

        def search_organisation
          run_mock
          result = @mock_controller.search_organisation
          response_result(result)
        end

        def manage_organisations
          @mock_controller = Api::V1::ManageOrganisationsController.new
        end
      end
    end
  end
end
