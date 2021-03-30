module Api
  module V1
    module Mock
      class RegisteredOrganisationsSchemesMockController < ApplicationMockController
        before_action :registered_organisations

        def search_organisation
          run_mock
          result = @mock_controller.search_organisation
          response_result(result)
        end

        def registered_organisations
          @mock_controller = Api::V1::RegisteredOrganisationsSchemesController.new
        end
      end
    end
  end
end
