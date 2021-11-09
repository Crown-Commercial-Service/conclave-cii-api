require 'rails_helper'

RSpec.describe ApiValidations::UpdateOrganisation, type: :model do
  describe 'validations' do
    let(:organisation_id) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisation_id: organisation_id, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: organisation_id) }
    let(:organisation_params) { { id: organisation_scheme_identifier.organisation_id, scheme: scheme_register.scheme_register_code } }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: organisation_scheme_identifier.organisation_id, scheme: scheme_register.scheme_register_code, organisation_id: organisation_scheme_identifier.organisation_id }).valid?).to eq true
      end
    end

    context 'when id and schema are missing' do
      it 'is not valid' do
        expect { described_class.new({ scheme: scheme_register.scheme_register_code, organisation_id: organisation_scheme_identifier.organisation_id }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisation_id is missing' do
      it 'is not valid' do
        expect { described_class.new({ identifier: { id: 'test', scheme: 'test' } }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
