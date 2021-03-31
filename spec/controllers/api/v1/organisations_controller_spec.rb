require 'rails_helper'

RSpec.describe Api::V1::OrganisationsController, type: :controller do
  before do
    MockingService::MockApis.new
    request.headers['x-api-key'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
  end

  describe '#search' do
    it 'search companies house' do
      get :search_organisation, params: { scheme: 'GB-COH', id: '02012345' }
      expect(response.status).to eq(200)
    end

    it 'search D and B' do
      get :search_organisation, params: { scheme: 'US-DUN', id: '606123456' }
      expect(response.status).to eq(200)
    end

    it 'search Find that charity' do
      get :search_organisation, params: { scheme: 'GB-CHC', id: '222123' }
      expect(response.status).to eq(200)
    end
  end
end
