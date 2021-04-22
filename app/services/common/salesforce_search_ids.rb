module Common
  class SalesforceSearchIds
    URN = 'urn'.freeze
    ID = 'id'.freeze
    SFURN = 'sfurn'.freeze
    SFID = 'sfid'.freeze

    def self.account_id_types
      [Common::SalesforceSearchIds::SFURN, Common::SalesforceSearchIds::SFID]
    end
  end
end
