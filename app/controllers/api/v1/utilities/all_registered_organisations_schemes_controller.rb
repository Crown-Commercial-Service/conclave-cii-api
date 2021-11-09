module Api
  module V1
    module Utilities
      class AllRegisteredOrganisationsSchemesController < ActionController::API
        include Authorize::User
        rescue_from ApiValidations::ApiError, with: :return_error_code
        before_action :validate_ccs_admin_or_delete_token
        before_action :validate_all_params

        def search_all_organisation
          result_all = Common::ApiHelper.return_all_organisation_schemes(params[:ccs_org_id])
          if result_all.present?
            render json: result_all[0], status: :ok
          else
            render json: '', status: :not_found
          end
        end

        def validate_all_params
          validate = ApiValidations::ManageRegisteredOrganisation.new(params)
          render json: validate.errors, status: :bad_request unless validate.valid?
        end

        private

        def return_error_code(code)
          render json: '', status: code.to_s
        end
      end
    end
  end
end
