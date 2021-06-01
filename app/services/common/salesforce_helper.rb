module Common
  class SalesforceHelper
    def initialize(results, ccs_org_id)
      super()
      @error = nil
      @results = results
      @ccs_org_id = ccs_org_id
    end

    def fetch_salesforce_record
      @results = Salesforce::AdditionalIdentifier.new(@results).build_response if @results.present?
    end

    def check_record_exists
      OrganisationSchemeIdentifier.find_by(ccs_org_id: @ccs_org_id, scheme_code: Common::AdditionalIdentifier::SCHEME_CCS)
    end

    def insert_salesforce_record
      fetch_salesforce_record
      insert_if_not_exists
    end

    def insert_if_not_exists
      additional_identifiers if check_record_exists.blank? && @results[:additionalIdentifiers].present?
    end

    def additional_identifiers
      identifier_ids = [Common::AdditionalIdentifier::SCHEME_CCS]
      @results[:additionalIdentifiers].each do |user_params|
        add_additional_identifier(user_params) if identifier_ids.include? user_params[:scheme]
      end
    end

    def add_additional_identifier(additional_identifier)
      organisation = OrganisationSchemeIdentifier.new
      organisation.scheme_code = additional_identifier[:scheme]
      organisation.scheme_org_reg_number = additional_identifier[:id]
      organisation.uri = additional_identifier[:uri]
      organisation.legal_name = additional_identifier[:legalName]
      organisation.ccs_org_id = @ccs_org_id
      organisation.primary_scheme = false
      organisation.hidden = true
      organisation.save
    end
  end
end
