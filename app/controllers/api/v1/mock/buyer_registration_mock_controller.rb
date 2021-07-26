module Api
  module V1
    module Mock
      class BuyerRegistrationMockController < ApplicationMockController
        before_action :buyer_registration

        def create_buyer
          if params[:account_id].blank? || params[:account_id_type].blank?
            render json: '', status: :bad_request
            return
          end

          run_mock
          result = @mock_controller.create_buyer(mock_req: true)
          response_result(result)
        end

        def buyer_registration
          @mock_controller = Api::V1::BuyerRegistrationController.new
        end
      end
    end
  end
end