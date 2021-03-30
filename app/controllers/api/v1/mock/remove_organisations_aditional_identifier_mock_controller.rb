module Api
  module V1
    module Mock
      class RemoveOrganisationsAditionalIdentifierMockController < ApplicationMockController
        before_action :remove_organisations_aditional_identifier

        def delete_addtional_identifier
          run_mock
          result = @mock_controller.delete_addtional_identifier
          response_result(result)
        end

        def remove_organisations_aditional_identifier
          @mock_controller = Api::V1::RemoveOrganisationsAditionalIdentifierController.new
        end
      end
    end
  end
end
