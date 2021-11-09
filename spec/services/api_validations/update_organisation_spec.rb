require 'rails_helper'

RSpec.describe ApiValidations::UpdateOrganisation, type: :model do
  describe 'validations' do
    let(:organisationId) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisationId: organisationId, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: organisationId) }
    let(:organisation_params) { { id: organisation_scheme_identifier.organisationId, scheme: scheme_register.scheme_register_code } }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: organisation_scheme_identifier.organisationId, scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier.organisationId }).valid?).to eq true
      end
    end

    context 'when id and schema are missing' do
      it 'is not valid' do
        expect { described_class.new({ scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier.organisationId }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisationId is missing' do
      it 'is not valid' do
        expect { described_class.new({ identifier: { id: 'test', scheme: 'test' } }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
