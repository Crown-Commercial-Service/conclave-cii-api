require 'rails_helper'

RSpec.describe Api::V1::RegisteredOrganisationsSchemesController, type: :controller do
  describe 'search_organisation' do
    let(:clientid) { ENV['CLIENT_ID'] }
    let(:organisation_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV['ACCESS_ORGANISATION_ADMIN'], ciiOrgId: organisation_id, aud: ENV['CLIENT_ID'] }, 'test') }

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
        let(:organisation_id) { organisation_scheme_identifier.organisation_id.to_s }

        it 'returns 200' do
          get :search_organisation, params: { organisation_id: organisation_id }
          expect(response).to have_http_status(:ok)
        end
      end
      # Add these back once user authentication is enabled on this route
      # context 'when not found' do
      #   it 'returns 401' do
      #     get :search_organisation, params: { organisation_id: 'test', clientid: clientid }
      #     expect(response).to have_http_status(:unauthorized)
      #   end
      # end

      # context 'when invalid params' do
      #   it 'returns 401' do
      #     get :search_organisation, params: { organisation_id: nil, clientid: clientid }
      #     expect(response).to have_http_status(:unauthorized)
      #   end
      # end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation, params: { organisation_id: 29842981489214, clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :search_organisation, params: { organisation_id: 29842981489214, clientid: 'n8f23er9h349hh439h94' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
