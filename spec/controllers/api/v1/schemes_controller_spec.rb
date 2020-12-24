require 'rails_helper'

RSpec.describe Api::V1::SchemesController, type: :controller do
  before do
    FactoryBot.create :scheme_register
  end

  describe 'GET schemes' do
    it 'has a 200 status code' do
      get :schemes
      expect(response.status).to eq(200)
    end

    it 'Has scheme_register_code' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]['scheme_register_code']).to eq('GB-CCC')
    end

    it 'Has scheme_name' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]['scheme_name']).to eq('Example charity orginsation')
    end

    it 'Has scheme_uri' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]['scheme_uri']).to eq('http://www.example.org.uk')
    end

    it 'Has scheme_identifier' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]['scheme_identifier']).to eq('Registered Charity Number')
    end

    it 'Has scheme_country_code' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]['scheme_country_code']).to eq('GB')
    end
  end
end
