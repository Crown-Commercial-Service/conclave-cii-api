module Api
  module V1
    class OrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params

      def search_organisation
        scheme_result = api_result
        if scheme_result.blank?
          render json: '', status: :not_found
        else
          render json: scheme_result
        end
      end

      def validate_params
        validate = ApiValidations::Scheme.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      private

      def api_result
        return Common::ApiHelper.return_mock_duns if Common::ApiHelper.find_mock_duns_org(params[:scheme], params[:id])

        search_api_with_params = SearchApi.new(params[:id], params[:scheme])
        search_api_with_params.call
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
