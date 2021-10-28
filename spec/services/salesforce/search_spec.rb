require 'rails_helper'

RSpec.describe Salesforce::Search, type: :services do
  before do
    MockingService::MockApis.new
  end

  describe 'Search salesforce records' do
    it 'Search Companies house record' do
      company_scheme = { identifier: { scheme: 'GB-COH', id: '02012345' } }
      result = described_class.new(company_scheme[:identifier][:id], company_scheme[:identifier][:scheme]).fetch_results
      expect(result).to eq({ id: 'NSO7IUSHF98HFP9WEH9FFZ~56734560025', legalName: 'Dummy organisation', scheme: 'GB-CCS', uri: '/services/data/v46.0/subjects/Accout/NSO7IUSHF98HFP9WEH9FFZ' })
    end

    it 'Search DUNS record' do
      company_scheme = { identifier: { scheme: 'US-DUN', id: '101123456' } }
      result = described_class.new(company_scheme[:identifier][:id], company_scheme[:identifier][:scheme]).fetch_results
      expect(result).to eq({ id: 'NSO7IUSHF98HFP9WEH9FHE~56734565478', legalName: 'Dummy organisation', scheme: 'GB-CCS', uri: '/services/data/v46.0/subjects/Accout/NSO7IUSHF98HFP9WEH9FHE' })
    end
  end
end
