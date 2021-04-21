# require 'rails_helper'

# RSpec.describe Api::V1::Mock::OrganisationsMockController, type: :controller do
#   before do
#     MockingService::MockApis.new
#     request.headers['x-api-key'] = '1B4B9BBC9ADA4EA65E98A9A32F8D4'
#   end

#   describe 'GET API calls search_organisation' do
#     it 'return companies house api response' do
#       get :search_organisation, params: { scheme: 'GB-COH', id: '02412345' }
#       expect(response.status).to eq(200)
#     end

#     it 'return D and B api response' do
#       get :search_organisation, params: { scheme: 'US-DUN', id: '404123456' }
#       expect(response.status).to eq(200)
#     end

#     it 'return Find that charity api response' do
#       get :search_organisation, params: { scheme: 'GB-CHC', id: '606123' }
#       expect(response.status).to eq(200)
#     end
#   end
# end
