require 'rails_helper'

RSpec.describe FindThatCharity::Contact, type: :model do
  describe '#build_response' do
    it 'returns the build response' do
      expect(described_class.new({ 'email' => 'email', 'telephone' => 'telephone' }).build_response).to eq({ email: 'email', faxNumber: '', name: '', telephone: 'telephone', uri: '' })
    end
  end
end
