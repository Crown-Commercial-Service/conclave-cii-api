require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController do
  describe 'search_organisation' do
    context 'when authorized' do
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
      end

      describe '#search' do
        it 'search companies house' do
          get :search_organisation, params: { scheme: 'GB-COH', id: '02012345' }
          expect(response).to have_http_status(:ok)
        end

        it 'search D and B' do
          get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find that charity' do
          get :search_organisation, params: { scheme: 'GB-CHC', id: '222123' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier US-DUN-1111....' do
          get :search_organisation, params: { scheme: 'GB-COH', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier SF-ID-1111....' do
          get :search_organisation, params: { scheme: 'SF-ID', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the duns test identifier SF-URN-1111....' do
          get :search_organisation, params: { scheme: 'SF-URN', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search Find the companies house test identifier GB-COH-1111....' do
          get :search_organisation, params: { scheme: 'US-DUN', id: '111111111' }
          expect(response).to have_http_status(:ok)
        end

        it 'search nhs' do
          get :search_organisation, params: { scheme: 'GB-NHS', id: 'A23' }
          expect(response).to have_http_status(:ok)
        end

        it 'search invalid params' do
          get :search_organisation, params: { scheme: 'INVALID', id: '12345' }
          expect(response).to have_http_status(:not_found)
        end

        it 'search no params' do
          get :search_organisation, params: { scheme: '', id: '' }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
