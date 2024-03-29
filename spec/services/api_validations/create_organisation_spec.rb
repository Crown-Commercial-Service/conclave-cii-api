require 'rails_helper'

RSpec.describe ApiValidations::CreateOrganisation, type: :model do
  describe 'validations' do
    let(:ccs_org_id) { '101123' }
    let(:scheme_register) { create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code) }
    let(:organisation_params) { { id: organisation_scheme_identifier.ccs_org_id, scheme: scheme_register.scheme_register_code } }

    describe 'identifier' do
      context 'when present' do
        it 'is valid' do
          validator = described_class.new({ identifier: organisation_params, 'identifier' => organisation_params })
          expect(validator.valid?).to be true
        end
      end

      context 'when not present' do
        it 'is not valid' do
          validator = described_class.new({ test: 'invalid' })
          expect { validator.valid? }.to raise_exception(ApiValidations::ApiError)
        end
      end
    end
  end
end
