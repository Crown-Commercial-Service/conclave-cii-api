require 'rails_helper'

RSpec.describe FindThatCharity::Identifier, type: :model do
  let(:result) do
    {
      'name' => 'Charity Example 101123',
      'charityNumber' => '101123',
      'links' => [
        {
          'site' => 'Charity Commission England and Wales',
          'url' => 'http://www.example.org.uk',
          'orgid' => 'GB-CHC-101123'
        },
        {
          'site' => 'Charity1',
          'url' => 'http://www.example.org.uk',
          'orgid' => 'GB-CHC-101123'
        },
        {
          'site' => 'Charity2',
          'url' => 'http://www.example.org.uk',
          'orgid' => 'GB-CHC-101123'
        },
        {
          'site' => 'Charity3',
          'url' => 'http://www.example.org.uk',
          'orgid' => 'GB-CHC-101123'
        }
      ]
    }
  end

  before do
    additional_identifier = instance_double(Common::AdditionalIdentifier)
    allow(Common::AdditionalIdentifier).to receive(:new).and_return(additional_identifier)
    allow(additional_identifier).to receive(:return_uri).and_return('Charity3')
  end

  describe '#build_response' do
    it 'returns the build response' do
      expect(described_class.new('101123', result).build_response).to eq({ id: '101123', legalName: 'Charity Example 101123', scheme: '101123', uri: 'http://www.example.org.uk' })
    end
  end
end
