module Api
  module V1
    module Testing
      class CrudTestingController < ActionController::API
        include Authorize::Token
        before_action :validate_api_key

        def remove_orginisation
          delete_org if params[:org_ccs_id].present?
          render json: [], status: :ok
        end

        def delete_org
          OrganisationSchemeIdentifier.where(organisation_id: params[:org_ccs_id].to_s).delete_all
        end

        def search_org
          return if find_org_ccs_id.blank?

          scheme = OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :organisation_id, :primary_scheme, :hidden, 'scheme_code AS scheme', :uri, :legal_name).where(organisation_id: find_org_ccs_id.organisation_id).as_json(except: :id)
          if scheme.present?
            render json: scheme, status: :ok
          else
            render json: '', status: :not_found
          end
        end

        private

        def find_org_ccs_id
          OrganisationSchemeIdentifier.find_by(scheme_org_reg_number: params[:id].to_s)
        end
      end
    end
  end
end
