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
          OrganisationSchemeIdentifier.where(ccs_org_id: params[:org_ccs_id].to_s).delete_all
        end

        def search_org
          scheme = OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :ccs_org_id).where(scheme_org_reg_number: params[:id].to_s).as_json(except: :id)
          if scheme.present?
            render json: scheme, status: :ok
          else
            render json: '', status: :not_found
          end
        end
      end
    end
  end
end
