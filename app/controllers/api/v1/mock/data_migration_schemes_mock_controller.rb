module Api
  module V1
    module Mock
      class DataMigrationSchemesMockController < ApplicationMockController
        before_action :data_migration_schemes

        def dm_schemes_helper
          run_mock
          @mock_controller.dm_schemes_helper
          disable_mock_service
        end

        def data_migration_schemes
          @mock_controller = Api::V1::DataMigrationSchemesController.new
        end
      end
    end
  end
end
