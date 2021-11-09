require 'rails_helper'

RSpec.describe ApiValidations::RemoveOrganisationAdditionalIdentifier, type: :model do
  describe 'validations' do
    let(:organisationId) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisationId: organisationId, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: organisationId) }
    let(:organisation_params) { { id: organisation_scheme_identifier.organisationId, scheme: scheme_register.scheme_register_code } }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: 24325263, scheme: 'GB-COH', organisationId: organisation_scheme_identifier.organisationId }).valid?).to eq true
      end
    end

    context 'when identifier is missing' do
      it 'is not valid' do
        expect { described_class.new({ organisationId: organisation_scheme_identifier.organisationId }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisationId is missing is missing' do
      it 'is not valid' do
        expect { described_class.new({ identifier: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
