module RegistryUpdate
  module UpdateScheme
    def registry_check
      search_registry
      # contact_srevice = RegistryUpdate::ContactService.new
      # contact_srevice.connect_contat_api
    end

    def find_org_with_id(ccs_org_id)
      OrganisationSchemeIdentifier.where(ccs_org_id: ccs_org_id, admin_updated: false)
    end

    def find_org_with_params
      find_org_with_id(params[:ccs_org_id]) if params[:ccs_org_id].present?
    end

    def search_registry
      return unless find_org_with_params.present?
      find_org_with_params.each do |scheme|
        results = api_search_result(scheme[:scheme_org_reg_number], scheme[:scheme_code], scheme[:ccs_org_id])
        update_record(results) if results.present?
      end
    end

    def api_search_result(scheme_id, scheme, ccs_org_id)
      search_api_with_params = SearchApi.new(scheme_id, scheme, ccs_org_id)
      search_api_with_params.call
    end

    def update_record(api_result)
      update_primary(api_result[:identifier]) if !api_result.nil? && api_result[:identifier].present?
    end

    def search_organisation_scheme(scheme_org_reg_number, scheme_code)
      organisation = OrganisationSchemeIdentifier.where(scheme_org_reg_number: scheme_org_reg_number, scheme_code: scheme_code, admin_updated: false, primary_scheme: true).first
      find_org_with_id(organisation[:ccs_org_id]) if organisation.present?
    end

    def update_primary(identifier)
      filter_date = Date.today - ENV['SUBTRACT_REGISTRY_UPDATE_DAYS'].to_i
      organisation = OrganisationSchemeIdentifier.where(scheme_org_reg_number: identifier[:id], scheme_code: identifier[:scheme], admin_updated: false).where("? >= DATE(updated_at)", filter_date.to_s).first
      if_changed_update(organisation, identifier) if organisation.present?
    end

    def if_changed_update(organisation, identifier)
      return unless identifier[:uri] != organisation[:uri] || identifier[:legalName] != organisation[:legalName]

      organisation[:uri] = identifier[:uri]
      organisation[:legal_name] = identifier[:legalName]
      organisation.save
    end

    def find_scheme_from_params
      return unless params[:identifier].present?

      if params[:identifier][:scheme].present?
        params[:identifier][:scheme]
      elsif params[:scheme].present?
        params[:scheme]
      end
    end
  end
end
