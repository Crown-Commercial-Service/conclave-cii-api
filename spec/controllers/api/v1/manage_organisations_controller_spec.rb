require 'rails_helper'

RSpec.describe Api::V1::ManageOrganisationsController, type: :controller do
  describe 'search_organisation' do
    let(:clientid) { ENV.fetch('CLIENT_ID', nil) }
    let(:ccs_org_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil), ciiOrgId: ccs_org_id, aud: ENV.fetch('CLIENT_ID', nil) }, 'test') }

    context 'when authorized' do
      let(:ccs_org_id) { '101123' }
      let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
      let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code) }
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

      before do
        client_registered = FactoryBot.create :client
        request.headers['x-api-key'] = client_registered.api_key
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        stub_request(:post, "http://www.test.com/security/tokens/validation?client-id=#{clientid}")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => "Bearer #{jwt_token}",
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'Faraday v1.3.0'
            }
          )
          .to_return(status: 200, body: 'true', headers: {})
        stub_request(:get, "https://findthatcharity.uk/orgid/GB-CHC-#{ccs_org_id}.json")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v1.3.0'
            }
          )
          .to_return(status: 200, body: response_body.to_json, headers: {})
      end

      context 'when success' do
        it 'returns 200' do
          post :search_organisation, params: { id: organisation_scheme_identifier.ccs_org_id.to_s, scheme: scheme_register.scheme_register_code, ccs_org_id: organisation_scheme_identifier.ccs_org_id.to_s, clientid: clientid }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 404' do
          post :search_organisation, params: { id: 'test', scheme: 'test', ccs_org_id: organisation_scheme_identifier.ccs_org_id.to_s, clientid: clientid }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        post :search_organisation, params: { id: 'test', scheme: 'test', ccs_org_id: 21342414, clientid: 'sbdiwqhg9d13g2gg3171284' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        post :search_organisation, params: { id: 'test', scheme: 'test', ccs_org_id: 21342414, clientid: 'sbdiwqhg9d13g2gg3171284' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
