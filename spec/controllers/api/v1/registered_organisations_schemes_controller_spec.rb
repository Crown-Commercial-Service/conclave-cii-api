require 'rails_helper'

RSpec.describe Api::V1::RegisteredOrganisationsSchemesController, type: :controller do
  describe 'search_organisation' do
    let(:clientid) { ENV['CLIENT_ID'] }
    let(:ccs_org_id) { nil }
    let(:id) { nil }
    let(:scheme) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: ccs_org_id, aud: ENV['CLIENT_ID'] }, 'test') }

    context 'when authorized' do
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
      end

      context 'when success' do
        let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier) }
        let(:ccs_org_id) { organisation_scheme_identifier.ccs_org_id.to_s }

        it 'returns 200' do
          get :search_organisation, params: { ccs_org_id: ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when org_id not found' do
        it 'returns 404' do
          get :search_organisation, params: { ccs_org_id: 'test', clientid: clientid }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when empty params' do
        it 'returns 400' do
          get :search_organisation, params: { ccs_org_id: '', clientid: clientid }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when id not found' do
        it 'returns 404' do
          get :search_organisation_by_scheme, params: { id: 123456, scheme: 'GB-COH', clientid: clientid }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when invalid scheme' do
        it 'returns 400' do
          get :search_organisation_by_scheme, params: { scheme: 'HB-CHH', id:123456, clientid: clientid }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401 for org_id' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation, params: { ccs_org_id: 29842981489214, clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 for scheme' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation_by_scheme, params: { id: 123456, scheme: 'GB-COH', clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401 for org_id' do
        get :search_organisation, params: { ccs_org_id: 29842981489214, clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 for scheme' do
        get :search_organisation, params: { cid: 123456, scheme: 'GB-COH', clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
