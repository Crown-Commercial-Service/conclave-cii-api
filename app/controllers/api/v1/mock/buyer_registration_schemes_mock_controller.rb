module Api
    module V1
        module Mock
            class BuyerRegistrationSchemesMockController < ApplicationMockController
                before_action :buyer_registration_schemes

                def buyer_schemes
                run_mock
                @mock_controller.buyer_schemes
                disable_mock_service
                end

                def buyer_registration_schemes
                    @mock_controller = Api::V1::BuyerRegistrationSchemesController.new
                end
            end
        end
    end
end
