require 'rails_helper'

RSpec.describe Api::V1::BuyerRegistrationController, type: :controller do
  describe 'create_buyer' do
    context 'when authorized' do
      before do
        request.headers['x-api-key'] = '6348G438RT834GR4827GRO834G8G348RO8238'
        sf_params = {
          'username' => ENV['SALESFORCE_USERNAME'],
          'password' => ENV['SALESFORCE_PASSWORD'] + ENV['SALESFORCE_SECURITY_TOKEN'],
          'grant_type' => 'password',
          'client_id' => ENV['SALESFORCE_CLIENT_ID'],
          'client_secret' => ENV['SALESFORCE_CLIENT_SECRET']
        }
        token_response = File.read('spec/stub_response/tokens/salesforce_token.json')
        sf_response = File.read('spec/stub_response/salesforce/GB-CHC-101123.json')

        valid_id = 'NSO7IUSHF98HFP9WEH9FFG'
        invalid_id = 'NSO7IUSHF98HFP9WEH9FFH'

        stub_request(:post, "#{ENV['SALESFORCE_AUTH_URL']}/services/oauth2/token")
          .with(
            body: sf_params,
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'Faraday v1.3.0'
            }
          )
          .to_return(status: 200, body: token_response, headers: {})
        stub_request(:get, "#{ENV['SALESFORCE_AUTH_URL']}/services/data/v45.0/query?q=SELECT%20ID,name,Status__c,Supplier_DUNS_Number__c,Company_Registration_Number__c,Account_URN__c%20FROM%20account%20WHERE%20Id='#{valid_id}'")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer t07891Fbasibd60NM9rW9basidj49w7ig7R2S9',
              'User-Agent' => 'Faraday v1.3.0'
            }
          )
          .to_return(status: 200, body: sf_response, headers: {})
        stub_request(:get, "#{ENV['SALESFORCE_AUTH_URL']}/services/data/v45.0/query?q=SELECT%20ID,name,Status__c,Supplier_DUNS_Number__c,Company_Registration_Number__c,Account_URN__c%20FROM%20account%20WHERE%20Id='#{invalid_id}'")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer t07891Fbasibd60NM9rW9basidj49w7ig7R2S9',
              'User-Agent' => 'Faraday v1.3.0'
            }
          )
          .to_return(status: 404, body: '', headers: {})
      end

      context 'when success' do
        it 'returns 201' do
          post :create_buyer, params: { account_id_type: 'SF-ID', account_id: '001b000003YNtGBAA1' }
          expect(response).to have_http_status(:created)
        end
      end

      # context 'when conflict' do
      #   it 'returns 409' do
      #     post :create_buyer, params: { account_id_type: 'SF-ID', account_id: 'NSO7IUSHF98HFP9WEH9FFG' }
      #     expect(response).to have_http_status(:conflict)
      #   end
      # end

      context 'when not found' do
        it 'returns 404' do
          post :create_buyer, params: { account_id_type: 'SF-ID', account_id: 'NSO7IUSHF98HFP9WEH9FFH' }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when invalid params' do
        it 'returns 404' do
          post :create_buyer, params: { account_id_type: 'sfurd', account_id: 'NSO7IUSHF98HFP9WEH9FFG' }
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when no params' do
        it 'returns 404' do
          post :create_buyer, params: { account_id_type: '', account_id: '' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when invalid ApiKey' do
      it 'returns 401' do
        request.headers['x-api-key'] = 'invalid'
        post :create_buyer, params: { account_id_type: 'sfurd', account_id: 'NSO7IUSHF98HFP9WEH9FFG' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when invalid request header' do
      it 'returns 401' do
        request.headers['Apikey'] = ''
        post :create_buyer, params: { account_id_type: 'sfurd', account_id: 'NSO7IUSHF98HFP9WEH9FFG' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no ApiKey' do
      it 'returns 401' do
        post :create_buyer, params: { account_id_type: 'sfurd', account_id: 'NSO7IUSHF98HFP9WEH9FFG' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
