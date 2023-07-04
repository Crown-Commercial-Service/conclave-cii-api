require 'rails_helper'

RSpec.describe ApiValidations::ManageRegisteredOrganisation, type: :model do
  describe 'validations' do
    let(:ccs_org_id) { '101123' }
    let(:scheme_register) { create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code) }
    let(:organisation_params) { { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code } }

    context 'when ccs_org_id is present' do
      it 'is valid' do
        expect(described_class.new({ identifier: organisation_params, 'identifier' => organisation_params, ccs_org_id: organisation_scheme_identifier.ccs_org_id }).valid?).to be true
      end
    end

    context 'when ccs_org_id is invalid' do
      it 'is not valid' do
        expect { described_class.new({ ccs_org_id: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when ccs_org_id is missing' do
      it 'is not valid' do
        expect { described_class.new({ test: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
