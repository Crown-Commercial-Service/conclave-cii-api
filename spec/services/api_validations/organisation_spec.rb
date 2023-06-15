require 'rails_helper'

RSpec.describe ApiValidations::Organisation, type: :model do
  describe 'validations' do
    let(:ccs_org_id) { '101123' }
    let(:scheme_register) { create(:scheme_register, scheme_register_code: 'GB-CHC') }
    let(:organisation_scheme_identifier) { create(:organisation_scheme_identifier, ccs_org_id: ccs_org_id, scheme_code: scheme_register.scheme_register_code) }
    let(:organisation_params) { { scheme: 'GB-COH', id: '125656234' } }

    context 'when organisation is present' do
      it 'is valid' do
        expect(described_class.new({ organisation: [organisation_params], 'organisation' => [organisation_params] }).valid?).to be true
      end
    end

    context 'when organisation is missing' do
      it 'is not valid' do
        expect { described_class.new({ 'organisation' => [scheme: 'test1', id: 'test2'] }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
