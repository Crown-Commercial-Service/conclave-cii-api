module Common
  class SalesforceSearchIds
    URN = 'urn'.freeze
    ID = 'id'.freeze
    SFURN = 'sfurn'.freeze
    SFID = 'sfid'.freeze

    def self.account_id_types_salesforce
      [Common::SalesforceSearchIds::SFURN, Common::SalesforceSearchIds::SFID]
    end

    def self.account_id_types_all
      [Common::SalesforceSearchIds::SFURN, Common::SalesforceSearchIds::SFID, Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE, Common::AdditionalIdentifier::SCHEME_DANDB, Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY, Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY, Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY, Common::AdditionalIdentifier::SCHEME_NHS]
    end
  end
end
