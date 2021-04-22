module Salesforce
  class SalesforceBuyerRegistration < Salesforce::Search
    def build_arguments
      case @scheme_id
      when Common::SalesforceSearchIds::ID
        salesforce_id
      when Common::SalesforceSearchIds::URN
        salesforce_urn
      end
    end

    def salesforce_id
      "Id='#{@id_number}'"
    end

    def salesforce_urn
      "Account_URN__c='#{@id_number}'"
    end
  end
end
