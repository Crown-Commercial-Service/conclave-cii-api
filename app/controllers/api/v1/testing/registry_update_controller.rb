module Api
  module V1
    module Testing
      class RegistryUpdateController < ActionController::API
        include Authorize::Token
        before_action :validate_api_key
        before_action :validate_params

        def index
          update_registry_data
          render json: [], status: :ok
        end

        private

        def update_registry_data
          scheme_result = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: params[:id].to_s)
          scheme_result.legal_name = params[:identifier][:legal_name]
          scheme_result.uri = params[:identifier][:uri]
          scheme_result.save
          # OrganisationSchemeIdentifier.update(legal_name: params[:identifier][:legalName].to_s, uri: params[:identifier][:uri].to_s).where(cc_org_id: params[:cc_org_id])
        end

        def find_org_ccs_id
          OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: params[:id].to_s)
        end

        def validate_params
          validate = ApiValidations::ManageRegisteredOrganisation.new(params)
          render json: validate.errors, status: :bad_request unless validate.valid?
        end
      end
    end
  end
end
