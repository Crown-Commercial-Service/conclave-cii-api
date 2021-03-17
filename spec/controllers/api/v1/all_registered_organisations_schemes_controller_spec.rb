require 'rails_helper'

RSpec.describe Api::V1::AllRegisteredOrganisationsSchemesController, type: :controller do
  describe 'search_organisation' do
    context 'when authenticated' do
      before do
        request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
        get :search_organisation
      end

      context 'when success' do
        let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier) }

        it 'returns 200' do
          get :search_organisation, params: { ccs_org_id: organisation_scheme_identifier.ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 404' do
          get :search_organisation, params: { ccs_org_id: '125656234' }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when invalid params' do
        it 'returns 400' do
          expect(response).to have_http_status(:bad_request)
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

    # context 'when no ApiKey' do
    #   it 'returns 401' do
    #     expect(response).to have_http_status(:unauthorized)
    #   end
    # end
  end
end
