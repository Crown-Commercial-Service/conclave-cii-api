require 'rails_helper'

RSpec.describe Api::V1::AllRegisteredOrganisationsSchemesController do
  describe 'search_organisation' do
    let(:clientid) { ENV.fetch('CLIENT_ID', nil) }
    let(:ccs_org_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV.fetch('ACCESS_CCS_ADMIN', nil), ciiOrgId: ccs_org_id, aud: ENV.fetch('CLIENT_ID', nil) }, 'test') }

    before do
      stub_request(:post, "http://www.test.com/aws/security/tokens/validation?client-id=#{clientid}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => "Bearer #{jwt_token}",
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => 'Faraday v1.10.3'
          }
        )
        .to_return(status: 200, body: 'true', headers: {})
    end

    context 'when authorized' do
      before do
        client_registered = create(:client)
        request.headers['x-api-key'] = client_registered.api_key
        request.headers['Authorization'] = "Bearer #{jwt_token}"
      end

      context 'when success' do
        let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier) }
        let(:ccs_org_id) { organisation_scheme_identifier.ccs_org_id.to_s }

        it 'returns 200' do
          get :search_organisation, params: { ccs_org_id: ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        let(:ccs_org_id) { '125656234' }

        it 'returns 404' do
          get :search_organisation, params: { ccs_org_id: ccs_org_id }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when invalid params' do
        it 'returns 404' do
          get :search_organisation, params: { ccs_org_id: 'null' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation, params: { ccs_org_id: 'null' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :search_organisation, params: { ccs_org_id: 'null' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
