module Api
  module V1
    module Mock
      class RemoveOrganisationsAditionalIdentifierMockController < ApplicationMockController

        def delete_addtional_identifier
          mock = MockingService::MockApis.new
          organisations = Api::V1::RemoveOrganisationsAditionalIdentifierController.new
          organisations.request = request
          organisations.response = response
          scheme_result = organisations.delete_addtional_identifier
          mock.disable_mock_service

          if scheme_result.blank?
            render json: '', status: :not_found
          else
            render json: scheme_result
          end
        end
      end
    end
  end
end
