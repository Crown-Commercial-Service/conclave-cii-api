module Api
  module V1
    module Mock
      class RemoveOrganisationsAdditionalIdentifierMockController < ApplicationMockController
        before_action :remove_additional_organisations

        def delete_additional_identifier
          run_mock
          org = @mock_controller.find_organisation
          @mock_controller.delete_additional_identifier if org.present?
          delete_additional_response_result(org)
        end

        def remove_additional_organisations
          @mock_controller = Api::V1::RemoveOrganisationsAdditionalIdentifierController.new
        end
      end
    end
  end
end
