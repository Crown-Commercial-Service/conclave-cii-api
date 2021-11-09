require 'rails_helper'

RSpec.describe ApiValidations::Scheme, type: :model do
  describe 'validations' do
    let(:scheme_register) { FactoryBot.create(:scheme_register) }
    let(:organisation_scheme_identifier) { FactoryBot.create(:organisation_scheme_identifier, scheme_code: scheme_register.scheme_register_code) }
    let(:organisation_scheme_identifier1) { FactoryBot.create(:organisation_scheme_identifier) }

    context 'when all params are present' do
      it 'is valid' do
        expect(described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier.organisationId }).valid?).to eq true
      end
    end

    context 'when scheme is missing' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when scheme is invalid' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: 'invalid', organisationId: organisation_scheme_identifier.organisationId }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when id is missing' do
      it 'is not valid' do
        expect { described_class.new({ scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier.organisationId }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisationId is invalid' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: scheme_register.scheme_register_code, organisationId: 'invalid' }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisationId is missing' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: scheme_register.scheme_register_code }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end

    context 'when organisationId is from a different organisation_scheme' do
      it 'is not valid' do
        expect { described_class.new({ id: organisation_scheme_identifier.scheme_org_reg_number, scheme: scheme_register.scheme_register_code, organisationId: organisation_scheme_identifier1.organisationId }).valid? }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
