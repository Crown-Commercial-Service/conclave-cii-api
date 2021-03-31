require 'rails_helper'

RSpec.describe ApiLogging::Logger, type: :model do
  describe '#warning' do
    let(:warn_message) { 'test' }

    it 'returns a rails warn' do
      allow(Rails.logger).to receive(:warn)
      described_class.warning(warn_message)
      expect(Rails.logger).to have_received(:warn)
    end
  end
end
