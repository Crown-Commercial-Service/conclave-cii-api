module Common
  class RegisteredOrganisationResponse
    def initialize(ccs_org_id, active: false)
      super()
      @ccs_org_id = ccs_org_id
      @results = active.blank? ? search_organisation : search_organisation_all
      @primary_identifier = []
      @additional_identifier = []
    end

    def search_organisation
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme).where(ccs_org_id: @ccs_org_id).where(active: true)
    end

    def search_organisation_all
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme).where(ccs_org_id: @ccs_org_id)
    end

    def response_payload
      build_response
      [
        name: '',
        identifier: @primary_identifier,
        additionalIdentifiers: @additional_identifier,
        address: address_response,
        contactPoint: contact_response
      ]
    end

    def build_response
      @results.each do |result|
        @primary_identifier.push(indetifier_scheme(result)) if result.primary_scheme
        @additional_identifier.push(indetifier_scheme(result)) unless result.primary_scheme
      end
    end

    def indetifier_scheme(indetifier)
      {
        scheme: indetifier.scheme_code,
        id: indetifier.scheme_org_reg_number,
        legalName: '',
        uri: ''
      }
    end

    def contact_response
      {
        name: '',
        email: '',
        telephone: '',
        faxNumber: '',
        url: ''
      }
    end

    def address_response
      {
        streetAddress: '',
        locality: '',
        region: '',
        postalCode: '',
        countryName: ''
      }
    end
  end
end
