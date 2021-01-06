require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController, type: :controller do
  before do
    request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
  end

  describe 'GET API calls search_org' do
    it 'return companies house api response' do
      get :search_org, params: { scheme_id: 'GB-COH', organisation_id: '125656234' }
      expect(response.status).to eq(200)
    end

    it 'return D and B api response' do
      get :search_org, params: { scheme_id: 'US-DUN', organisation_id: '500dsdasdsad' }
      expect(response.status).to eq(200)
    end
  end
end
