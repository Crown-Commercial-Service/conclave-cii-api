require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController, type: :controller do
  describe 'search_organisation' do
    context 'when authorized' do
      before do
        MockingService::MockApis.new
        client_registered = FactoryBot.create :client
        request.headers['x-api-key'] = client_registered.api_key
        stub_request(:get, "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations/XJY").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'User-Agent'=>'Faraday v1.3.0'
           }).
         to_return(status: 200, body: "", headers: {})
      end

      describe '#search' do
        it 'search companies house' do
          get :search_organisation, params: { scheme: 'GB-COH', id: '02012345' }
          expect(response.status).to eq(200)
        end

        it 'search D and B' do
          get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
          expect(response.status).to eq(200)
        end

        it 'search Find that charity' do
          get :search_organisation, params: { scheme: 'GB-CHC', id: '222123' }
          expect(response.status).to eq(200)
        end

        it 'search nhs' do
          get :search_organisation, params: { scheme: 'GB-NHS', id: 'XJY' }
          expect(response.status).to eq(200)
        end

        it 'search invalid params' do
          get :search_organisation, params: { scheme: 'INVALID', id: '12345' }
          expect(response.status).to eq(404)
        end

        it 'search no params' do
          get :search_organisation, params: { scheme: '', id: '' }
          expect(response.status).to eq(400)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
