module Api
  module V1
    class MultipleOrganisationsController < ActionController::API
      include Authorize::Token
      rescue_from ApiValidations::ApiError, with: :return_error_code
      before_action :validate_api_key
      before_action :validate_params
      attr_accessor :scheme_result

      def search_organisation
        search_org = search_api
        if search_org.blank?
          render json: [], status: :not_found
        else
          render json: search_org
        end
      end

      def validate_params
        validate = ApiValidations::Organisation.new(params)
        render json: validate.errors, status: :bad_request unless validate.valid?
      end

      private

      def search_api
        params['organisation'].each do |_user_params|
          api_result(scheme_param)
        end
        result
      end

      def api_result(scheme_param)
        search_api_with_params = SearchApi.new(scheme_param[:id], scheme_param[:scheme])
        @scheme_result.push(search_api_with_params.call)
      end

      def return_error_code(code)
        render json: '', status: code.to_s
      end
    end
  end
end
