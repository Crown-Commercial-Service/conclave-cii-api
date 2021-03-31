require 'rails_helper'

RSpec.describe FindThatCharity::Address, type: :model do
  describe '#build_response' do
    it 'returns response' do
      expect(described_class.new({ 'address' => { 'streetAddress' => 'street', 'addressLocality' => 'locality', 'addressRegion' => 'region', 'postalCode' => 'postcode', 'addressCountry' => 'country' } }).build_response).to eq({ countryName: 'country', locality: 'locality', postalCode: 'postcode', region: 'region', streetAddress: 'street' })
    end
  end
end
