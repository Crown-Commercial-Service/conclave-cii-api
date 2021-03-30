module Api
  module V1
    module Mock
      class RemoveOrganisationsMockController < ApplicationMockController
        before_action :remove_organisations

        def delete_orginisation
          run_mock
          result = @mock_controller.delete_addtional_identifier
          response_result(result)
        end

        def remove_organisations
          @mock_controller = Api::V1::RemoveOrganisationsController.new
        end
      end
    end
  end
end
