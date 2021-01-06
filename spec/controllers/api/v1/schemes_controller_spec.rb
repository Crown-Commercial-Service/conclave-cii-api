require 'rails_helper'

RSpec.describe Api::V1::SchemesController, type: :controller do
  before do
    request.headers['Apikey'] = 'F3CAE7C17E276974E88351712957D'
  end

  describe 'GET schemes' do
    it 'has a 200 status code' do
      get :schemes
      expect(response.status).to eq(200)
    end

    it 'Has scheme_register_code' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]).to include('scheme_register_code')
    end

    it 'Has scheme_name' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]).to include('scheme_name')
    end

    it 'Has scheme_uri' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]).to include('scheme_uri')
    end

    it 'Has scheme_identifier' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]).to include('scheme_identifier')
    end

    it 'Has scheme_country_code' do
      get :schemes
      result = JSON.parse(response.body)
      expect(result[0]).to include('scheme_country_code')
    end
  end
end
