module Common
  class RegisteredOrganisationResponse
    def initialize(ccs_org_id, hidden: true)
      super()
      @ccs_org_id = ccs_org_id
      @results = hidden.blank? ? search_organisation : search_organisation_all
      @primary_name = ''
      @primary_identifier = {}
      @additional_identifier = []
    end

    def search_organisation
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme, :uri, :legal_name).where(ccs_org_id: @ccs_org_id).where(hidden: false)
    end

    def search_organisation_all
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme, :hidden, :uri, :legal_name).where(ccs_org_id: @ccs_org_id)
    end

    def response_payload
      build_response
      [
        identifier: @primary_identifier,
        additionalIdentifiers: @additional_identifier
      ]
    end

    def response_payload_migration
      build_response
      [
        organisationId: @ccs_org_id,
        identifier: @primary_identifier,
        additionalIdentifiers: @additional_identifier
      ]
    end

    def build_response
      @results.each do |result|
        build_response_structure(result)
      end
    end

    def build_response_structure(result)
      @primary_identifier = indetifier_primary_scheme(result) if result.primary_scheme
      @additional_identifier.push(indetifier_scheme(result)) unless result.primary_scheme
    end

    def primary_scheme_name(indetifier)
      indetifier.legal_name.present? ? indetifier.legal_name : ''
    end

    def indetifier_primary_scheme(indetifier)
      {
        scheme: indetifier.scheme_code,
        id: indetifier.scheme_org_reg_number,
        legalName: legal_name(indetifier),
        uri: uri(indetifier)
      }
    end

    def indetifier_scheme(indetifier)
      scheme_indetifier = {
        scheme: indetifier.scheme_code,
        id: indetifier.scheme_org_reg_number,
        legalName: legal_name(indetifier),
        uri: uri(indetifier)
      }

      scheme_indetifier[:hidden] = hidden_status(indetifier) if indetifier.attributes.key?('hidden')

      scheme_indetifier
    end

    def hidden_status(indetifier)
      indetifier.hidden ? true : false
    end

    def legal_name(indetifier)
      indetifier.legal_name.present? ? indetifier.legal_name : ''
    end

    def uri(indetifier)
      indetifier.uri.present? ? indetifier.uri : ''
    end
  end
end
