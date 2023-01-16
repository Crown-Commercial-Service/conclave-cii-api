require 'rails_helper'

RSpec.describe SchemeRegister, type: :model do
  let(:scheme_register) { FactoryBot.create :scheme_register }

  describe 'Scheme Register' do
    it 'Has scheme_register_code' do
      expect(scheme_register.scheme_register_code).to eq('GB-CCC')
    end

    it 'Has scheme_name' do
      expect(scheme_register.scheme_name).to eq('Example charity orginsation')
    end

    it 'Has scheme_uri' do
      expect(scheme_register.scheme_uri).to eq('http://www.example.org.uk')
    end

    it 'Has scheme_identifier' do
      expect(scheme_register.scheme_identifier).to eq('Registered Charity Number')
    end

    it 'Has scheme_country_code' do
      expect(scheme_register.scheme_country_code).to eq('GB')
    end
  end
end
