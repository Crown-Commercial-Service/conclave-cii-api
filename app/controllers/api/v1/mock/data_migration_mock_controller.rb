module Api
  module V1
    module Mock
      class DataMigrationMockController < ApplicationMockController
        before_action :data_migration

        def create_org_profile
          if params[:account_id].blank? || params[:account_id_type].blank?
            render json: '', status: :bad_request
            return
          end

          run_mock
          result = @mock_controller.create_org_profile(mock_req: true)
          response_result(result)
        end

        def data_migration
          @mock_controller = Api::V1::DataMigrationController.new
        end
      end
    end
  end
end
