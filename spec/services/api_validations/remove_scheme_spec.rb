require 'rails_helper'

RSpec.describe ApiValidations::RemoveScheme, type: :model do
  describe 'validations' do
    let(:ccs_org_id) { '101123' }
    let(:scheme_register) { create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: ccs_org_id) }
    let(:organisation_params) { { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code } }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: scheme_register.scheme_register_code }).valid?).to be true
      end
    end

    context 'when scheme is invalid' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: 'invalid' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when id is invalid' do
      it 'is not valid' do
        expect { described_class.new({ id: 'invalid', scheme: scheme_register.scheme_register_code }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when id is missing' do
      it 'is valid' do
        expect(described_class.new({ scheme: scheme_register.scheme_register_code }).valid?).to be true
      end
    end
  end
end
