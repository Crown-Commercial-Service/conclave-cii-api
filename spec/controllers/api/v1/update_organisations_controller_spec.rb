require 'rails_helper'

RSpec.describe Api::V1::UpdateOrganisationsController, type: :controller do
  describe 'index' do
    context 'when authorized' do
      let(:clientid) { ENV['CLIENT_ID'] }
      let(:organisationId) { nil }
      let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: organisationId, aud: ENV['CLIENT_ID'] }, 'test') }
      let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
      let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisationId: organisationId, scheme_code: scheme_register.scheme_register_code) }
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
        stub_request(:get, "https://findthatcharity.uk/orgid/GB-CHC-#{organisationId}.json")
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
        let(:organisationId) { '101123' }

        it 'returns 201' do
          put :index, params: { organisationId: organisationId, scheme: scheme_register.scheme_register_code, id: organisation_scheme_identifier.organisationId, clientid: clientid }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when no ApiKey' do
        it 'returns 404' do
          request.headers['x-api-key'] = 'invalid'
          put :index, params: { organisationId: 'test', id: 'test', scheme: 'test' }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when the first identifier cannot be found' do
        let(:organisationId) { '101123' }
        let(:organisationId_second) { '101122' }
        let(:scheme_register_second) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
        let(:organisation_scheme_identifier_second) { FactoryBot.create(:organisation_scheme_identifier, organisationId: organisationId_second, scheme_code: scheme_register_second.scheme_register_code) }

        it 'returns 404' do
          put :index, params: { organisationId: organisationId, id: organisation_scheme_identifier_second.organisationId, scheme: organisation_scheme_identifier_second.scheme_code, clientid: clientid }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when duplicate' do
        let(:organisationId) { '101123' }
        let(:organisationId_second) { '101122' }
        let(:scheme_register_second) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
        let(:organisation_scheme_identifier_second) { FactoryBot.create(:organisation_scheme_identifier, organisationId: organisationId_second, scheme_code: scheme_register_second.scheme_register_code, scheme_org_reg_number: organisationId_second) }
        let(:response_body_second) do
          {
            id: "GB-CHC-#{organisationId_second}",
            name: "Charity Example #{organisationId_second}",
            charityNumber: organisationId_second,
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
                orgid: "GB-CHC-#{organisationId_second}"
              },
              {
                site: 'Charity1',
                url: 'http://www.example.org.uk',
                orgid: "GB-CHC-#{organisationId_second}"
              },
              {
                site: 'Charity2',
                url: 'http://www.example.org.uk',
                orgid: "GB-CHC-#{organisationId_second}"
              },
              {
                site: 'Charity3',
                url: 'http://www.example.org.uk',
                orgid: "GB-CHC-#{organisationId_second}"
              }
            ],
            orgIDs: ["GB-CHC-#{organisationId_second}"],
            linked_records: [
              {
                orgid: "GB-CHC-#{organisationId_second}",
                url: "http://www.example.org.uk/GB-CHC-#{organisationId_second}.json"
              }
            ]
          }
        end

        before do
          organisation_scheme_identifier
          stub_request(:get, "https://findthatcharity.uk/orgid/GB-CHC-#{organisationId_second}.json")
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Faraday v1.3.0'
              }
            )
            .to_return(status: 200, body: response_body_second.to_json, headers: {})
        end

        it 'returns duplicate' do
          put :index, params: { organisationId: organisationId, id: organisation_scheme_identifier_second.organisationId, scheme: organisation_scheme_identifier_second.scheme_code, clientid: clientid }
          expect(response).to have_http_status(:conflict)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        put :index, params: { organisationId: 2621648264217, scheme: 'BO-COH', id: 621428764, clientid: 'nwodh9823hr823gro823gro3grg32ogro34g' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when not found' do
      it 'returns 401' do
        put :index, params: { organisationId: 'test', id: 'test', scheme: 'test', clientid: 'nwodh9823hr823gro823gro3grg32ogro34g' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
