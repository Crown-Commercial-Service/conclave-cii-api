module Api
  module V1
    class DataMigrationSchemesController < ActionController::API
      include Authorize::IntegrationToken
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_integration_key

      def dm_schemes_helper
        render json: Common::SalesforceSearchIds.account_id_types_all, status: :ok
      end
    end
  end
end
