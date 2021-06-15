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
      record = @result['records'][0]

      if record.key?('Company_Registration_Number__c') && record['Company_Registration_Number__c'].present? && record['Company_Registration_Number__c'] != 'Unknown' # 'str.downcase' causes a 500 error.
        [record['Supplier_DUNS_Number__c'], record['Company_Registration_Number__c']]
      elsif record.key?('Supplier_DUNS_Number__c') && record['Supplier_DUNS_Number__c'].present? && record['Supplier_DUNS_Number__c'] != 'Unknown' # 'str.downcase' causes a 500 error.
        [record['Supplier_DUNS_Number__c']]
      else
        []
      end
    end
  end
end
