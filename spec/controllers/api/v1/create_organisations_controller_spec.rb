require 'rails_helper'

RSpec.describe Api::V1::CreateOrganisationsController do
  describe 'index' do
    let(:clientid) { ENV.fetch('CLIENT_ID', nil) }
    let(:organisation_id) { nil }
    let(:jwt_token) { JWT.encode({ roles: ENV.fetch('ACCESS_ORGANISATION_ADMIN', nil), ciiOrgId: organisation_id, aud: ENV.fetch('CLIENT_ID', nil) }, 'test') }
    
    after do
      WebMock::RequestRegistry.instance.requested_signatures.hash.each do |request_signature, _|
        puts "WebMock request made: #{request_signature}"
      end
    end

    context 'when success' do
      before do
        [
          { scheme_register_code: 'US-DUN', scheme_name: 'Dun & Bradstreet', scheme_uri: 'https://plus.dnb.com', scheme_country_code: 'US', scheme_identifier: 'DUNS Number' },
          { scheme_register_code: 'GB-COH', scheme_name: 'Companies House', scheme_uri: 'https://api.company-information.service.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'Company Registration Number' },
          { scheme_register_code: 'GB-CHC', scheme_name: 'Charity Commission for England and Wales', scheme_uri: 'https://findthatcharity.uk', scheme_country_code: 'GB', scheme_identifier: 'Registered Charity Number' },
          { scheme_register_code: 'GB-NHS', scheme_name: 'National Health Service Organisations Registry', scheme_uri: 'https://www.crowncommercial.gov.uk', scheme_country_code: 'GB', scheme_identifier: 'NHS Registered Number' }
        ].each do |scheme|
          SchemeRegister.find_or_create_by!(scheme_register_code: scheme[:scheme_register_code]) do |record|
            record.scheme_name = scheme[:scheme_name]
            record.scheme_uri = scheme[:scheme_uri]
            record.scheme_country_code = scheme[:scheme_country_code]
            record.scheme_identifier = scheme[:scheme_identifier]
          end
        end

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
          WebMock.assert_requested(:get, /searchorganisation/, at_least_times: 1)
        end

        it 'create primary record with additional identifiers' do
          param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '505123456' } }
          param_post_dand_b[:additional_identifiers] = [{ scheme: 'GB-COH', id: '09012345' }]
          post :index, params: param_post_dand_b
          expect(response).to have_http_status(:created)
          expect(response.body).to include('organisationId')
          WebMock.assert_requested(:get, /searchorganisation/, at_least_times: 1)
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
