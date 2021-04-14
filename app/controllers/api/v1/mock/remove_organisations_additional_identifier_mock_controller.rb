module Api
  module V1
    module Mock
      class RemoveOrganisationsAdditionalIdentifierMockController < ApplicationMockController
        before_action :remove_organisations_additional_identifier

        def delete_additional_identifier
          run_mock
          result = @mock_controller.delete_additional_identifier
          delete_response_result(result)
        end

        def remove_organisations_additional_identifier
          @mock_controller = Api::V1::RemoveOrganisationsAdditionalIdentifierController.new
        end
      end
    end
  end
end
