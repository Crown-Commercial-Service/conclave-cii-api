require 'rails_helper'

RSpec.describe Api::V1::Mock::CreateOrganisationsMockController, type: :controller do
  before do
    params = [
      { scheme: 'US-DUN', id: '500191747' },
      { scheme: 'GB-COH', id: '125656234' },
      { scheme: 'GB-CHC', id: '1088678' },
      { scheme: 'GB-CHC', id: '1088571' }
    ]
    params.each do |param|
      MockingService::ApiStub.new(param)
    end
    request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
    request.headers['CONTENT_TYPE'] = 'application/json'
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST D & B create an organisation record' do
    it 'create primary record' do
      param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '500191747' } }
      post :index, params: param_post_dand_b
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end

    it 'create primary record with additional identifiers' do
      param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '500191747' } }
      param_post_dand_b[:additional_identifiers] = [{ scheme: 'GB-COH', id: '125656234' }]
      post :index, params: param_post_dand_b
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end

  describe 'POST Companies house create an organisation record' do
    it 'create primary record Companies house' do
      param_post_companies_house = { identifier: { scheme: 'GB-COH', id: '125656234' } }
      post :index, params: param_post_companies_house
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end

  describe 'POST Charities create an organisation record' do
    it 'create primary record Charities' do
      param_find_that_charity = { identifier: { scheme: 'GB-CHC', id: '1088678' } }
      post :index, params: param_find_that_charity
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end
end
