require 'rails_helper'

RSpec.describe Api::V1::RemoveOrganisationsAdditionalIdentifierController, type: :controller do
  describe 'delete_additional_identifier' do
    context 'when authenticated' do
      let(:clientid) { 'validID' }
      let(:ccs_org_id) { nil }
      let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: ccs_org_id }, 'test') }
      let(:scheme_register) { FactoryBot.create(:scheme_register) }
      let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, scheme_org_reg_number: ccs_org_id, scheme_code: scheme_register.scheme_register_code, ccs_org_id: ccs_org_id, primary_scheme: false) }

      before do
        request.headers['x-api-key'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
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
        let(:ccs_org_id) { '101123' }

        it 'returns 200' do
          delete :delete_additional_identifier, params: { identifier: { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code }, ccs_org_id: organisation_scheme_identifier.ccs_org_id, clientid: clientid }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 401' do
          delete :delete_additional_identifier, params: { ccs_org_id: 'test', clientid: clientid }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when invalid params' do
        let(:ccs_org_id) { '101123' }

        it 'returns 400' do
          delete :delete_additional_identifier, params: { ccs_org_id: ccs_org_id, clientid: clientid }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        delete :delete_additional_identifier
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
