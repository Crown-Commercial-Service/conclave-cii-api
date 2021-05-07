module Salesforce
  class AdditionalIdentifier
    def initialize(results)
      super()
      @error = nil
      @found_record = false
      @results = results
      @valid_schemes = [Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE, Common::AdditionalIdentifier::SCHEME_DANDB]
    end

    def build_response #
      search_only_validated_primary ######1
      find_from_additional_identifiers unless @found_record # calls method when @found_record = falsey #############1
      @results
    end

    private

    def search_only_validated_primary ######2
      salesforce_from_primary_scheme if @valid_schemes.include? @results[:identifier][:scheme]
    end

    def search_only_validated_additional_identifiers(identifier) #############3
      salesforce_from_additional_identifiers(identifier[:id], identifier[:scheme]) if @valid_schemes.include? identifier[:scheme]
    end

    def get_salesforce(scheme_number, scheme_id) ######4 #############5
      salesforce = Salesforce::Search.new(scheme_number, scheme_id)
      salesforce.fetch_results
    end

    def salesforce_from_primary_scheme ######3
      salesforce_result = get_salesforce(@results[:identifier][:id], @results[:identifier][:scheme])
      update_additional_identifiers(salesforce_result)
    end

    def salesforce_from_additional_identifiers(id, scheme) #############4
      salesforce_result = get_salesforce(id, scheme)
      update_additional_identifiers(salesforce_result)
    end

    def update_additional_identifiers(salesforce_result) ######5 #############6
      return unless salesforce_result.present? && @found_record == false

      @results[:additionalIdentifiers].push(salesforce_result)
      @found_record = true unless @results[:identifier][:scheme] == Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE || Common::AdditionalIdentifier::SCHEME_DANDB # GB-COH or US-DUN.
    end

    def find_from_additional_identifiers #############2
      @results[:additionalIdentifiers].each do |identifier|
        search_only_validated_additional_identifiers(identifier) unless @found_record
      end
    end

    def ccs_scheme(results)
      salesforce_result = get_salesforce
      results[:additionalIdentifiers].push(salesforce_result) if salesforce_result.present?
      results
    end
  end
end
