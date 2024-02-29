module Api
  module V1
    module Testing
      class RegistryUpdateController < ActionController::API
        include Authorize::Token
        before_action :validate_api_key
        before_action :validate_params

        def index
          update_registry_data
          if find_org_ccs_id.present?
            render json: find_org_ccs_id, status: :ok
          else
            render json: '', status: :bad_request
          end
        end

        private

        def update_registry_data
          scheme_result = OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: params[:identifier][:id].to_s, ccs_org_id: params[:ccs_org_id].to_s, scheme_code: params[:identifier][:scheme].to_s)
          save_registry_data(scheme_result) if scheme_result.present?
        end

        # rubocop:disable Metrics/AbcSize
        def save_registry_data(scheme_result)
          scheme_result.legal_name = params[:identifier][:legal_name]
          scheme_result.uri = params[:identifier][:uri]
          scheme_result.admin_updated = params[:identifier][:admin_updated] if params[:identifier][:admin_updated].to_s.present?
          scheme_result.updated_at =  DateTime.parse(params[:identifier][:updated_at]) if params[:identifier][:updated_at].to_s.present?
          scheme_result.hidden = params[:identifier][:hidden] if params[:identifier][:hidden].to_s.present?
          scheme_result.primary_scheme = params[:identifier][:primary_scheme] if params[:identifier][:primary_scheme].to_s.present?

          scheme_result.save
        end

        # rubocop:enable Metrics/AbcSize
        def find_org_ccs_id
          OrganisationSchemeIdentifier.select(:ccs_org_id, :scheme_code, :scheme_org_reg_number, :primary_scheme, :uri, :legal_name, :admin_updated, :updated_at, :hidden).find_by(scheme_org_reg_number: params[:identifier][:id].to_s, ccs_org_id: params[:ccs_org_id].to_s, scheme_code: params[:identifier][:scheme].to_s)
        end

        def validate_params
          validate = ApiValidations::ManageRegisteredOrganisation.new(params)
          render json: validate.errors, status: :bad_request unless validate.valid?
        end
      end
    end
  end
end
