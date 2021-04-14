require 'rails_helper'

RSpec.describe Api::V1::SchemesController, type: :controller do
  describe 'get' do
    context 'when authorized' do
      before do
        request.headers['x-api-key'] = 'F3CAE7C17E276974E88351712957D'
      end

      describe 'GET schemes' do
        it 'has a 200 status code' do
          get :schemes
          expect(response.status).to eq(200)
        end

        it 'Has scheme' do
          get :schemes
          result = JSON.parse(response.body)
          expect(result[0]).to include('scheme')
        end

        it 'Has scheme_name' do
          get :schemes
          result = JSON.parse(response.body)
          expect(result[0]).to include('scheme_name')
        end

        it 'Has scheme_country_code' do
          get :schemes
          result = JSON.parse(response.body)
          expect(result[0]).to include('scheme_country_code')
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['Apikey'] = 'invalid'
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
