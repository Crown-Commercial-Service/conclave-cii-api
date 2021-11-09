require 'rails_helper'

RSpec.describe ApiValidations::ManageOrganisation, type: :model do
  describe 'validations' do
    let(:organisation_id) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisation_id: organisation_id, scheme_code: scheme_register.scheme_register_code, scheme_org_reg_number: organisation_id) }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: organisation_scheme_identifier.organisation_id, scheme: scheme_register.scheme_register_code, organisation_id: organisation_scheme_identifier.organisation_id }).valid?).to eq true
      end
    end

    context 'when schema is missing' do
      it 'is not valid' do
        expect { described_class.new({ id: 'test', organisation_id: organisation_scheme_identifier.organisation_id }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when id is missing' do
      it 'is not valid' do
        expect { described_class.new({ scheme: 'test', organisation_id: organisation_scheme_identifier.organisation_id }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisation_id is missing' do
      it 'is not valid' do
        expect { described_class.new({ id: 'test', scheme: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
