require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController do
  describe 'search_organisation' do
    context 'when authorized' do
      before do
        MockingService::MockApis.new
        client_registered = create(:client)
        request.headers['x-api-key'] = client_registered.api_key
      end

      describe '#search' do
        it 'search companies house' do
          get :search_organisation, params: { scheme: 'GB-COH', id: '02012345' }
          expect(response).to have_http_status(:ok)
        end

        it 'search D and B' do
          get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find that charity' do
          get :search_organisation, params: { scheme: 'GB-CHC', id: '222123' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier US-DUN-1111....' do
          get :search_organisation, params: { scheme: 'GB-COH', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier SF-ID-1111....' do
          get :search_organisation, params: { scheme: 'SF-ID', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier SF-URN-1111....' do
          get :search_organisation, params: { scheme: 'SF-URN', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the companies house test identifier GB-COH-1111....' do
          get :search_organisation, params: { scheme: 'US-DUN', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search nhs' do
          get :search_organisation, params: { scheme: 'GB-NHS', id: 'A23' }
          expect(response).to have_http_status(:ok)
        end

        it 'search invalid params' do
          get :search_organisation, params: { scheme: 'INVALID', id: '12345' }
          expect(response).to have_http_status(:not_found)
        end

        it 'search no params' do
          get :search_organisation, params: { scheme: '', id: '' }
          expect(response).to have_http_status(:bad_request)
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
