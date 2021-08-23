require 'rails_helper'

RSpec.describe Salesforce::SalesforceBuyerRegistration, type: :services do
  describe 'build_arguments' do
    it 'Arguments with Salesforce ID' do
      result = described_class.new('IWDBI382RI4B8OIU', 'sfid').build_arguments
      expect(result).to eq("Id='IWDBI382RI4B8OIU'")
    end

    it 'Arguments with Salesforce URN' do
      result = described_class.new('IWDBI382RI4B8OIU', 'sfurn').build_arguments
      expect(result).to eq("Account_URN__c='IWDBI382RI4B8OIU'")
    end
  end
end
