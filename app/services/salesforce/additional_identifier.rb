module Salesforce
  class AdditionalIdentifier
    def initialize(results)
      super()
      @error = nil
      @found_record = false
      @results = results
      @valid_schemes = [Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE, Common::AdditionalIdentifier::SCHEME_DANDB]
    end

    def build_response
      search_only_validated_primary
      find_from_additional_identifiers unless @found_record
      @results
    end

    private

    def search_only_validated_primary
      salesforce_from_primary_scheme if @valid_schemes.include? @results[:identifier][:scheme]
    end

    def search_only_validated_additional_identifiers(identifier)
      salesforce_from_additional_identifiers(identifier[:id], identifier[:scheme]) if @valid_schemes.include? identifier[:scheme]
    end

    def get_salesforce(scheme_number, scheme_id)
      salesforce = Salesforce::Search.new(scheme_number, scheme_id)
      salesforce.fetch_results
    end

    def salesforce_from_primary_scheme
      salesforce_result = get_salesforce(@results[:identifier][:id], @results[:identifier][:scheme])
      update_additional_identifiers(salesforce_result)
    end

    def salesforce_from_additional_identifiers(id, scheme)
      salesforce_result = get_salesforce(id, scheme)
      update_additional_identifiers(salesforce_result)
    end

    def update_additional_identifiers(salesforce_result)
      return unless salesforce_result.present? && @found_record == false

      @results[:additionalIdentifiers].push(salesforce_result)
      @found_record = true
    end

    def find_from_additional_identifiers
      @results[:additionalIdentifiers].each do |identifier|
        search_only_validated_additional_identifiers(identifier)
      end
    end

    def ccs_scheme(results)
      salesforce_result = get_salesforce
      results[:additionalIdentifiers].push(salesforce_result) if salesforce_result.present?
      results
    end
  end
end
