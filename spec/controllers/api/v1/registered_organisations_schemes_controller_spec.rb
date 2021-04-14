require 'rails_helper'

RSpec.describe Api::V1::RegisteredOrganisationsSchemesController, type: :controller do
  describe 'search_organisation' do
    let(:clientid) { 'validID' }
    let(:ccs_org_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: ccs_org_id }, 'test') }

    context 'when authorized' do
      before do
        request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        stub_request(:post, "http://www.test.com/security/validate_token?clientid=#{clientid}")
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
          get :search_organisation, params: { ccs_org_id: ccs_org_id, clientid: clientid }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 401' do
          get :search_organisation, params: { ccs_org_id: 'test', clientid: clientid }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when invalid params' do
        it 'returns 401' do
          get :search_organisation, params: { ccs_org_id: nil, clientid: clientid }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['Apikey'] = 'invalid'
        get :search_organisation
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :search_organisation
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
