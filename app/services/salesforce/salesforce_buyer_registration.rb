module Salesforce
  class SalesforceBuyerRegistration < Salesforce::Search
    def build_arguments
      case @scheme_id
      when Common::SalesforceSearchIds::SFID
        salesforce_id
      when Common::SalesforceSearchIds::SFURN
        salesforce_urn
      end
    end

    def salesforce_id
      "Id='#{@id_number}'"
    end

    def salesforce_urn
      "Account_URN__c='#{@id_number}'"
    end

    def results
      results_array = []
      record = @result['records'][0]

      return unless record.key?('Company_Registration_Number__c') && record.key?('Supplier_DUNS_Number__c')

      results_array.push("GB-COH-#{record['Company_Registration_Number__c']}") if record['Company_Registration_Number__c'].present? && !!!(record['Company_Registration_Number__c'] =~ /[a-zA-Z]/)
      results_array.push("US-DUN-#{record['Supplier_DUNS_Number__c']}") if record['Supplier_DUNS_Number__c'].present? && !!!(record['Supplier_DUNS_Number__c'] =~ /[a-zA-Z]/)
      results_array
    end
  end
end
