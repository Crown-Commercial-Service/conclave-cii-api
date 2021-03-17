require 'rails_helper'

RSpec.describe Api::V1::CreateOrganisationsController, type: :controller do
  describe 'index' do
    context 'when authenticated' do
      before do
        request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
        post :index
      end

      context 'when success' do
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

        it 'returns 200' do
          post :index, params: { identifier: { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code } }
          expect(response).to have_http_status(:created)
        end
      end

      context 'when not found' do
        it 'returns 404' do
          post :index, params: { identifier: { id: 'test', scheme: 'test' } }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when invalid params' do
        it 'returns 400' do
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['Apikey'] = 'invalid'
        post :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # context 'when no ApiKey' do
    #   it 'returns 401' do
    #     expect(response).to have_http_status(:unauthorized)
    #   end
    # end
  end
end