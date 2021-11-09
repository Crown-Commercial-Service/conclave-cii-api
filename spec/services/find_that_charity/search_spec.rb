require 'rails_helper'

RSpec.describe FindThatCharity::Search, type: :model do
  let(:organisation_id) { '101123' }
  let(:scheme_register) { FactoryBot.create(:scheme_register) }
  let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisation_id: organisation_id, scheme_code: scheme_register.scheme_register_code) }
  let(:response_body) do
    {
      id: 'GB-CHC-101123',
      name: 'Charity Example 101123',
      charityNumber: '101123',
      companyNumber: nil,
      description: 'Charity Example Description',
      url: 'http://www.example.org.uk',
      dateRemoved: nil,
      active: true,
      parent: nil,
      organisationType: [
        'Registered Charity',
        'Registered Charity (England and Wales)'
      ],
      organisationTypePrimary: 'Registered Charity',
      alternateName: [],
      telephone: '07123456789',
      email: 'example@email.com',
      address: {
        streetAddress: '123 Example Street',
        addressLocality: 'Locality',
        postalCode: 'A1 2BC'
      },
      links: [

        {
          site: 'Charity Commission England and Wales',
          url: 'http://www.example.org.uk',
          orgid: 'GB-CHC-101123'
        },
        {
          site: 'Charity1',
          url: 'http://www.example.org.uk',
          orgid: 'GB-CHC-101123'
        },
        {
          site: 'Charity2',
          url: 'http://www.example.org.uk',
          orgid: 'GB-CHC-101123'
        },
        {
          site: 'Charity3',
          url: 'http://www.example.org.uk',
          orgid: 'GB-CHC-101123'
        }
      ],
      orgIDs: ['GB-CHC-101123'],
      linked_records: [
        {
          orgid: 'GB-CHC-101123',
          url: 'http://www.example.org.uk/GB-CHC-101123.json'
        }
      ]
    }
  end
  let(:result) do
    { additionalIdentifiers: [{ id: '101123', scheme: 'GB-CHC' }],
      address: { countryName: '', locality: 'Locality', postalCode: 'A1 2BC', region: '', streetAddress: '123 Example Street' },
      contactPoint: { email: 'example@email.com', faxNumber: '', name: '', telephone: '07123456789', uri: '' },
      identifier: { id: '101123', legalName: 'Charity Example 101123', scheme: 'GB-CCC', uri: '' },
      name: 'Charity Example 101123' }
  end

  before do
    stub_request(:get, 'https://findthatcharity.uk/orgid/GB-CCC-101123.json')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Faraday v1.3.0'
        }
      )
      .to_return(status: 200, body: response_body.to_json, headers: {})
  end

  describe '#fetch_results' do
    it 'returns the build response' do
      expect(described_class.new(organisation_scheme_identifier.organisation_id, scheme_register.scheme_register_code).fetch_results).to eq(result)
    end
  end
end
