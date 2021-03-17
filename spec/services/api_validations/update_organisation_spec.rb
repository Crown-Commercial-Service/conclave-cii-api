require 'rails_helper'

RSpec.describe ApiValidations::UpdateOrganisation, type: :model do
  describe 'validations' do
    let(:ccs_org_id) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: ccs_org_id) }
    let(:organisation_params) { { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code } }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ identifier: organisation_params, 'identifier' => organisation_params, ccs_org_id: organisation_scheme_identifier.ccs_org_id }).valid?).to eq true
      end
    end

    context 'when id and schema are missing' do
      it 'is not valid' do
        expect { described_class.new({ ccs_org_id: organisation_scheme_identifier.ccs_org_id }).valid? }.to raise_exception(NoMethodError)
      end
    end

    context 'when ccs_org_id is missing' do
      it 'is not valid' do
        expect { described_class.new({ identifier: { id: 'test', scheme: 'test' } }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
