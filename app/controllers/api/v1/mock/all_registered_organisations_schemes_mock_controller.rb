module Api
  module V1
    module Mock
      class AllRegisteredOrganisationsSchemesMockController < ApplicationMockController
        before_action :all_registered_organisations_schemes

        def search_organisation
          run_mock
          result = @mock_controller.search_organisation
          response_result(result)
        end

        def all_registered_organisations_schemes
          @mock_controller = Api::V1::AllRegisteredOrganisationsSchemesController.new
        end
      end
    end
  end
end
