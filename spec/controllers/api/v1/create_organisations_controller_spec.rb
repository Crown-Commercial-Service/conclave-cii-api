require 'rails_helper'

RSpec.describe Api::V1::CreateOrganisationsController, type: :controller do
  before do
    params = [
      { scheme: 'US-DUN', id: '500191747' },
      { scheme: 'GB-COH', id: '125656234' }
    ]
    params.each do |param|
      MockingService::ApiStub.new(param)
    end
    request.headers['Apikey'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
    request.headers['CONTENT_TYPE'] = 'application/json'
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST D & B create an organisation record' do
    before do
      @param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '500191747' } }
      @additional_dand_b = [{ scheme: 'GB-COH', id: '125656234' }]
    end

    it 'create primary record' do
      post :index, params: @param_post_dand_b
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end

    it 'create primary record with additional identifiers' do
      @param_post_dand_b[:additional_identifiers] = @additional
      post :index, params: @param_post_dand_b
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end

  describe 'POST Companies house create an organisation record' do
    before do
      @param_post_companies_house = { identifier: { scheme: 'GB-COH', id: '125656234' } }
    end

    it 'create primary record' do
      post :index, params: @param_post_companies_house
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end

  describe 'POST Charities create an organisation record' do
    before do
      @param_post_companies_house = { identifier: { scheme: 'GB-COH', id: '125656234' } }
    end

    it 'create primary record' do
      post :index, params: @param_post_companies_house
      expect(response.status).to eq(201)
      expect(response.body).to include('ccs_org_id')
    end
  end
end
