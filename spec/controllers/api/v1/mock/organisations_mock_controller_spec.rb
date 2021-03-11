require 'rails_helper'

RSpec.describe Api::V1::Mock::OrganisationsMockController, type: :controller do
  before do
    params = [
      { scheme: 'GB-COH', id: '125656234' },
      { scheme: 'US-DUN', id: '500191747' },
      { scheme: 'GB-CHC', id: '1088678' },
      { scheme: 'GB-CHC', id: '1088678' },
      { scheme: 'GB-CHC', id: '1088571' }
    ]
    params.each do |param|
      MockingService::ApiStub.new(param)
    end
    request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
  end

  describe 'GET API calls search_organisation' do
    it 'return companies house api response' do
      get :search_organisation, params: { scheme: 'GB-COH', id: '125656234' }
      expect(response.status).to eq(200)
    end

    it 'return D and B api response' do
      get :search_organisation, params: { scheme: 'US-DUN', id: '500191747' }
      expect(response.status).to eq(200)
    end

    it 'return Find that charity api response' do
      get :search_organisation, params: { scheme: 'GB-CHC', id: '1088678' }
      expect(response.status).to eq(200)
    end
  end
end
