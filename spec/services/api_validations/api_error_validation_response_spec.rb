require 'rails_helper'

RSpec.describe ApiValidations::ApiErrorValidationResponse, type: :model do
  describe '#call' do
    context 'when success' do
      it 'does not raise exception' do
        expect { described_class.new(nil).call }.not_to raise_exception
      end
    end

    context 'when bad request' do
      context 'when id is sent' do
        it 'does raise exception' do
          expect { described_class.new(:id).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when scheme is sent' do
        it 'does raise exception' do
          expect { described_class.new(:scheme).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when identifier is sent' do
        it 'does raise exception' do
          expect { described_class.new(:identifier).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when organisation is sent' do
        it 'does raise exception' do
          expect { described_class.new(:organisation).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when additional_identifiers is sent' do
        it 'does raise exception' do
          expect { described_class.new(:additional_identifiers).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when organisationId is sent' do
        it 'does raise exception' do
          expect { described_class.new(:organisationId).call }.to raise_exception(ApiValidations::ApiError)
        end
      end
    end

    context 'when not found' do
      context 'when no_scheme_found' do
        it 'does raise exception' do
          expect { described_class.new(:no_scheme_found).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when no_scheme_id_found' do
        it 'does raise exception' do
          expect { described_class.new(:no_scheme_id_found).call }.to raise_exception(ApiValidations::ApiError)
        end
      end

      context 'when organisationId_not_found' do
        it 'does raise exception' do
          expect { described_class.new(:organisationId_not_found).call }.to raise_exception(ApiValidations::ApiError)
        end
      end
    end

    context 'when duplicate response' do
      it 'does raise exception' do
        expect { described_class.new(:duplicate_id).call }.to raise_exception(ApiValidations::ApiError)
      end
    end
  end
end
