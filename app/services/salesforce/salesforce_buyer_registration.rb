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
      if @result['records'][0].key?('Company_Registration_Number__c')
        [@result['records'][0]['Supplier_DUNS_Number__c'], @result['records'][0]['Company_Registration_Number__c']]
      elsif @result['records'][0].key?('Supplier_DUNS_Number__c')
        [@result['records'][0]['Supplier_DUNS_Number__c']]
      else
        []
      end
    end
  end
end
