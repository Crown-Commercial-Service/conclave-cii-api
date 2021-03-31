module Api
  module V1
    module Mock
      class MultipleOrganisationsMockController < ApplicationMockController
        before_action :multiple_organisations

        def search_organisation
          run_mock
          result = @mock_controller.search_organisation
          response_result(result)
        end

        def multiple_organisations
          @mock_controller = Api::V1::MultipleOrganisationsController.new
        end
      end
    end
  end
end
