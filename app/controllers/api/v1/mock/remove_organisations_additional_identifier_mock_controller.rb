module Api
  module V1
    module Mock
      class RemoveOrganisationsAdditionalIdentifierMockController < ApplicationMockController
        before_action :remove_additional_organisations

        def delete_additional_identifier
          run_mock
          additional_org = @mock_controller.find_organisation
          primary_org_check = @mock_controller.primary_org_check
          @mock_controller.delete_additional_identifier if additional_org.present?
          delete_additional_response_result(additional_org, primary_org_check)
        end

        def remove_additional_organisations
          @mock_controller = Api::V1::RemoveOrganisationsAdditionalIdentifierController.new
        end
      end
    end
  end
end
