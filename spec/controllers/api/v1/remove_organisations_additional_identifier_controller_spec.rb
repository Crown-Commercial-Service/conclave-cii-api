require 'rails_helper'

RSpec.describe Api::V1::RemoveOrganisationsAdditionalIdentifierController, type: :controller do
  describe 'delete_additional_identifier' do
    context 'when authenticated' do
      let(:clientid) { ENV.fetch('CLIENT_ID', nil) }
      let(:ccs_org_id) { nil }
      let(:jwt_token) { JWT.encode({ roles: ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil), ciiOrgId: ccs_org_id, aud: ENV.fetch('CLIENT_ID', nil) }, 'test') }
      let(:scheme_register) { FactoryBot.create(:scheme_register) }
      let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, scheme_org_reg_number: ccs_org_id, scheme_code: scheme_register.scheme_register_code, ccs_org_id: ccs_org_id, primary_scheme: false) }

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
              'User-Agent' => 'Faraday v1.10.3'
            }
          )
          .to_return(status: 200, body: 'true', headers: {})
      end

      context 'when success' do
        let(:ccs_org_id) { '101123' }

        it 'returns 200' do
          delete :delete_additional_identifier, params: { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code, ccs_org_id: organisation_scheme_identifier.ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 401' do
          delete :delete_additional_identifier, params: { ccs_org_id: 'test', id: 32141244, scheme: 'GB-COH' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when invalid ApiKey' do
      let(:ccs_org_id) { '101123' }

      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        delete :delete_additional_identifier, params: { ccs_org_id: ccs_org_id, id: 32141244, scheme: 'GB-COH' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
