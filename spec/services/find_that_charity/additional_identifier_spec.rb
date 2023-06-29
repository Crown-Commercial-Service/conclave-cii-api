require 'rails_helper'

RSpec.describe FindThatCharity::AdditionalIdentifier, type: :model do
  let(:ccs_org_id) { '101123' }
  let(:scheme_register) { create(:scheme_register) }
  let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code) }
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
  let(:result) { { id: 101123, legalName: 'Charity Example 101123', scheme: 'GB-CCC', uri: '' } }

  before do
    stub_request(:get, "https://findthatcharity.uk/orgid/GB-CCC-#{ccs_org_id}.json")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Faraday v1.10.3'
        }
      )
      .to_return(status: 200, body: response_body.to_json, headers: {})
  end

  describe '#build_response' do
    it 'returns the build response' do
      expect(described_class.new(organisation_scheme_identifier.ccs_org_id, scheme_register.scheme_register_code).build_response).to eq(result)
    end
  end
end
