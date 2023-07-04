require 'rails_helper'

RSpec.describe Client do
  let(:client_registered) { create(:client) }
  let(:client_result) { described_class.find(client_registered.id) }

  describe 'Registered Client' do
    it 'Has name' do
      expect(client_registered.name).to eq('Example company')
      expect(client_result.name).to eq(client_registered.name)
    end

    it 'Has description' do
      expect(client_registered.description).to eq('Example company description')
      expect(client_result.description).to eq(client_registered.description)
    end

    it 'Has api_key' do
      expect(client_result.api_key).to eq(client_registered.api_key)
    end
  end
end
