module Common
  class RegisteredOrganisationResponse
    def initialize(ccs_org_id, active: false)
      super()
      @ccs_org_id = ccs_org_id
      @results = active.blank? ? search_organisation : search_organisation_all
      @primary_name = ''
      @primary_identifier = []
      @additional_identifier = []
    end

    def search_organisation
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme, :active, :uri, :legal_name).where(ccs_org_id: @ccs_org_id).where(active: true)
    end

    def search_organisation_all
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme, :active, :uri, :legal_name).where(ccs_org_id: @ccs_org_id)
    end

    def response_payload
      build_response
      [
        name: @primary_name,
        identifier: @primary_identifier,
        additionalIdentifiers: @additional_identifier
      ]
    end

    def build_response
      @results.each do |result|
        @primary_name = primary_scheme_name(result) if result.primary_scheme
        @primary_identifier.push(indetifier_primary_scheme(result)) if result.primary_scheme
        @additional_identifier.push(indetifier_scheme(result)) unless result.primary_scheme
      end
    end

    def primary_scheme_name(indetifier)
      indetifier.legal_name.present? ? indetifier.legal_name : ''
    end

    def indetifier_primary_scheme(indetifier)
      {
        scheme: indetifier.scheme_code,
        id: indetifier.scheme_org_reg_number,
        legalName: indetifier.legal_name.present? ? indetifier.legal_name : '',
        uri: indetifier.uri.present? ? indetifier.uri : '',
      }
    end

    def indetifier_scheme(indetifier)
      {
        scheme: indetifier.scheme_code,
        id: indetifier.scheme_org_reg_number,
        hidden: indetifier.active ? false : true,
        legalName: indetifier.legal_name.present? ? indetifier.legal_name : '',
        uri: indetifier.uri.present? ? indetifier.uri : '',
      }
    end
  end
end
