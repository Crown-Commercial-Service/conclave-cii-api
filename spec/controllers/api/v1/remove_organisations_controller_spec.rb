require 'rails_helper'

RSpec.describe Api::V1::RemoveOrganisationsController do
  describe 'delete_organisation' do
    context 'when authorized' do
      let(:scheme_register) { create(:scheme_register) }
      let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, scheme_org_reg_number: ccs_org_id, scheme_code: scheme_register.scheme_register_code, ccs_org_id: ccs_org_id) }

      before do
        request.headers['x-api-key'] = '6348G438RT834GR4827GRO834G8G348RO8238'
      end

      context 'when success' do
        let(:ccs_org_id) { '101123' }

        it 'returns 200' do
          delete :delete_organisation, params: { identifier: { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code }, ccs_org_id: organisation_scheme_identifier.ccs_org_id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when not found' do
        it 'returns 404' do
          delete :delete_organisation, params: { ccs_org_id: 'test' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        delete :delete_organisation, params: { ccs_org_id: 'test' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        delete :delete_organisation, params: { ccs_org_id: 'test' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
