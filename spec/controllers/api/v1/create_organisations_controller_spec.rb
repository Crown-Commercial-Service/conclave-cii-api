require 'rails_helper'

RSpec.describe Api::V1::CreateOrganisationsController do
  describe 'index' do
    let(:clientid) { ENV.fetch('CLIENT_ID', nil) }
    let(:organisation_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil), ciiOrgId: organisation_id, aud: ENV.fetch('CLIENT_ID', nil) }, 'test') }

    context 'when success' do
      before do
        MockingService::MockApis.new
        client_registered = create(:client)
        request.headers['x-api-key'] = client_registered.api_key
        request.headers['Authorization'] = "Bearer #{jwt_token}"
      end

      context 'when POST D & B create an organisation record' do
        it 'create primary record' do
          param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '404123456' } }
          post :index, params: param_post_dand_b
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end

        it 'create primary record with additional identifiers' do
          param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '505123456' } }
          param_post_dand_b[:additional_identifiers] = [{ scheme: 'GB-COH', id: '09012345' }]
          post :index, params: param_post_dand_b
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end

      context 'when POST Companies house create an organisation record' do
        it 'create primary record Companies house' do
          param_post_companies_house = { identifier: { scheme: 'GB-COH', id: '07612345' } }
          post :index, params: param_post_companies_house
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end

      context 'when POST test identifier NHS create an organisation record' do
        it 'create primary record NHS' do
          param_post_companies_house = { identifier: { scheme: 'GB-NHS', id: '111111111' } }
          post :index, params: param_post_companies_house
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end

      context 'when POST test identifier Saleforce ID create an organisation record' do
        it 'create primary record NHS' do
          param_post_companies_house = { identifier: { scheme: 'SF-ID', id: '111111111' } }
          post :index, params: param_post_companies_house
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end

      context 'when POST test identifier DUNs create an organisation record' do
        it 'create primary record NHS' do
          param_post_companies_house = { identifier: { scheme: 'US-DUN', id: '111111111' } }
          post :index, params: param_post_companies_house
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end

      context 'when POST invalid scheme does not save org' do
        it 'returns 404' do
          param_post_companies_house = { identifier: { scheme: 'US-DN', id: '111111111' } }
          post :index, params: param_post_companies_house
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when POST Charities create an organisation record' do
        it 'create primary record Charities' do
          param_find_that_charity = { identifier: { scheme: 'GB-CHC', id: '1012345' } }
          post :index, params: param_find_that_charity
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
        end
      end
    end
  end

  describe 'unauthorized' do
    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
