module Api
  module V1
    module Mock
      class RemoveOrganisationsAditionalIdentifierMockController < ApplicationMockController
        before_action :remove_organisations_aditional_identifier

        def delete_addtional_identifier
          run_mock
          result = @mock_controller.delete_addtional_identifier
          disable_mock_service
          if result.blank?
            render json: '', status: :ok
          else
            render json: '', status: :not_found
          end
        end

        def remove_organisations_aditional_identifier
          @mock_controller = Api::V1::RemoveOrganisationsAditionalIdentifierController.new
        end
      end
    end
  end
end
