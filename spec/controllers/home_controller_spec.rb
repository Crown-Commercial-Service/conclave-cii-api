require 'rails_helper'

RSpec.describe HomeController do
  describe 'GET index' do
    it 'has a 200 status code' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
