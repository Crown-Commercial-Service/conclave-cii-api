# require 'rails_helper'

# RSpec.describe Api::V1::Mock::CreateOrganisationsMockController, type: :controller do
#   before do
#     MockingService::MockApis.new
#     client_registered = FactoryBot.create :client
#     request.headers['x-api-key'] = client_registered.api_key
#     request.headers['CONTENT_TYPE'] = 'application/json'
#     request.headers['ACCEPT'] = 'application/json'
#   end

#   describe 'POST D & B create an organisation record' do
#     it 'create primary record' do
#       param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '101123456' } }
#       post :index, params: param_post_dand_b
#       expect(response.status).to eq(201)
#       expect(response.body).to include('organisation_id')
#     end

#     it 'create primary record with additional identifiers' do
#       param_post_dand_b = { identifier: { scheme: 'US-DUN', id: '101123456' } }
#       param_post_dand_b[:additional_identifiers] = [{ scheme: 'GB-COH', id: '125656234' }]
#       post :index, params: param_post_dand_b
#       expect(response.status).to eq(201)
#       expect(response.body).to include('organisation_id')
#     end
#   end

#   describe 'POST Companies house create an organisation record' do
#     it 'create primary record Companies house' do
#       param_post_companies_house = { identifier: { scheme: 'GB-COH', id: '02012345' } }
#       post :index, params: param_post_companies_house
#       expect(response.status).to eq(201)
#       expect(response.body).to include('organisation_id')
#     end
#   end

#   describe 'POST Charities create an organisation record' do
#     it 'create primary record Charities' do
#       param_find_that_charity = { identifier: { scheme: 'GB-CHC', id: '1012345' } }
#       post :index, params: param_find_that_charity
#       expect(response.status).to eq(201)
#       expect(response.body).to include('organisation_id')
#     end
#   end
# end
