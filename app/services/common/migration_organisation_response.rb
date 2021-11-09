module Common
  class MigrationOrganisationResponse < RegisteredOrganisationResponse
    def search_organisation_all_with_salesforce
      OrganisationSchemeIdentifier.select(:scheme_org_reg_number, :scheme_code, :primary_scheme, :uri, :legal_name).where(organisationId: @organisationId)
    end

    def response_payload_migration
      @results = search_organisation_all_with_salesforce
      build_response
      [
        organisationId: @organisationId,
        identifier: @primary_identifier,
        additionalIdentifiers: @additional_identifier
      ]
    end
  end
end
