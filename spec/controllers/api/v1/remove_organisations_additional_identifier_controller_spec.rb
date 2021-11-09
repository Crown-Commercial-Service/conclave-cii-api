require 'rails_helper'

RSpec.describe Api::V1::RemoveOrganisationsAdditionalIdentifierController, type: :controller do
  describe 'delete_additional_identifier' do
    context 'when authenticated' do
      let(:clientid) { ENV['CLIENT_ID'] }
      let(:organisationId) { nil }
      let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: organisationId, aud: ENV['CLIENT_ID'] }, 'test') }
      let(:scheme_register) { FactoryBot.create(:scheme_register) }
      let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, scheme_org_reg_number: organisationId, scheme_code: scheme_register.scheme_register_code, organisationId: organisationId, primary_scheme: false) }

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
        let(:organisationId) { '101123' }

        it 'returns 200' do
          delete :delete_additional_identifier, params: { id: organisation_scheme_identifier.organisationId, scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier.organisationId }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 401' do
          delete :delete_additional_identifier, params: { organisationId: 'test', id: 32141244, scheme: 'GB-COH' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when invalid ApiKey' do
      let(:organisationId) { '101123' }

      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        delete :delete_additional_identifier, params: { organisationId: organisationId, id: 32141244, scheme: 'GB-COH' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
