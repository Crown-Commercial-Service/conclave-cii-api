module Api
  module V1
    module Mock
      class SchemesMockController < ApplicationMockController
        before_action :schemes_init

        def schemes
          run_mock
          result = @mock_controller.schemes
          response_result(result)
        end

        def schemes_init
          @mock_controller = Api::V1::SchemesController.new
        end
      end
    end
  end
end
