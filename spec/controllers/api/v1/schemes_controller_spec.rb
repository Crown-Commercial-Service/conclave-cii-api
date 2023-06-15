require 'rails_helper'

RSpec.describe Api::V1::SchemesController do
  describe 'get' do
    context 'when authorized' do
      before do
        client_registered = create(:client)
        request.headers['x-api-key'] = client_registered.api_key
      end

      describe 'GET schemes' do
        it 'has a 200 status code' do
          get :schemes
          expect(response).to have_http_status(:ok)
        end

        it 'Has scheme' do
          get :schemes
          result = response.parsed_body
          expect(result[0]).to include('scheme')
        end

        it 'Has scheme_name' do
          get :schemes
          result = response.parsed_body
          expect(result[0]).to include('scheme_name')
        end

        it 'Has scheme_country_code' do
          get :schemes
          result = response.parsed_body
          expect(result[0]).to include('scheme_country_code')
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :schemes
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :schemes
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
