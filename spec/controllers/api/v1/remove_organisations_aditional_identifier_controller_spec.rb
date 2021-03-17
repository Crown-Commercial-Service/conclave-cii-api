require 'rails_helper'

RSpec.describe Api::V1::RemoveOrganisationsAditionalIdentifierController, type: :controller do
  describe 'delete_additional_identifier' do
    context 'when authenticated' do
      before do
        request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
      end

      context 'when success' do
        let(:ccs_org_id) { '101123' }
        let(:scheme_register) { FactoryBot.create(:scheme_register) }
        let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, scheme_org_reg_number: ccs_org_id, scheme_code: scheme_register.scheme_register_code, ccs_org_id: ccs_org_id, primary_scheme: false) }

        it 'returns 200' do
          delete :delete_addtional_identifier, params: { identifier: { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code }, ccs_org_id: organisation_scheme_identifier.ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 400' do
          delete :delete_addtional_identifier, params: { ccs_org_id: 'test' }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when invalid params' do
        it 'returns 400' do
          delete :delete_addtional_identifier
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['Apikey'] = 'invalid'
        delete :delete_addtional_identifier
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # context 'when no ApiKey' do
    #   it 'returns 401' do
    #     delete :delete_addtional_identifier
    #     expect(response).to have_http_status(:unauthorized)
    #   end
    # end
  end
end
