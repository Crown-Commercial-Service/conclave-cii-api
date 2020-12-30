module Api
  module V1
    class OrganisationsController < ActionController::API
      before_action :validate_params

      def search_org
        search_api = SearchApi.new(params[:orginasation_id], params[:scheme_id])
        search_api.call
        if search_api.blank?
          render json: [], status: :not_found
        else
          render json: search_api.result
        end
      end

      def validate_params
        validate = ApiValidation.new(params)
        render json: validate.errors unless validate.valid?
      end
    end
  end
end
