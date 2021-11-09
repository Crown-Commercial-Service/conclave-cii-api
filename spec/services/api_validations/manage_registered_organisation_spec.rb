require 'rails_helper'

RSpec.describe ApiValidations::ManageRegisteredOrganisation, type: :model do
  describe 'validations' do
    let(:organisation_id) { '101123' }
    let(:scheme_register) { FactoryBot.create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, organisation_id: organisation_id, scheme_code: scheme_register.scheme_register_code) }
    let(:organisation_params) { { id: organisation_scheme_identifier.organisation_id, scheme: scheme_register.scheme_register_code } }

    context 'when organisation_id is present' do
      it 'is valid' do
        expect(described_class.new({ identifier: organisation_params, 'identifier' => organisation_params, organisation_id: organisation_scheme_identifier.organisation_id }).valid?).to eq true
      end
    end

    context 'when organisation_id is invalid' do
      it 'is not valid' do
        expect { described_class.new({ organisation_id: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisation_id is missing' do
      it 'is not valid' do
        expect { described_class.new({ test: 'test' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
