module Api
  module V1
    module Mock
      class RemoveOrganisationsMockController < ApplicationMockController
        before_action :remove_organisations

        def delete_orginisation
          run_mock
          result = @mock_controller.delete_orginisation

          if result.blank?
            render json: '', status: :ok
          else
            render json: '', status: :not_found
          end
        end

        def remove_organisations
          @mock_controller = Api::V1::RemoveOrganisationsController.new
        end
      end
    end
  end
end
