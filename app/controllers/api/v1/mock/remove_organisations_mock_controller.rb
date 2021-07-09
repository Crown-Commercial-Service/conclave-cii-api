module Api
  module V1
    module Mock
      class RemoveOrganisationsMockController < ApplicationMockController
        before_action :remove_organisations

        def delete_organisation
          run_mock
          result = @mock_controller.delete_organisation
          delete_response_result(result)
        end

        def remove_organisations
          @mock_controller = Api::V1::RemoveOrganisationsController.new
        end
      end
    end
  end
end
