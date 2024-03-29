require 'rails_helper'

RSpec.describe 'Stub validations', type: :request do
  before do
    MockingService::MockApis.new
  end

  def get_params(filename)
    params = {}
    params[:scheme] = scheme(filename)
    params[:id] = scheme_id(filename)
    params
  end

  def scheme(filename)
    split_file_path = filename.split('-')
    "#{split_file_path[0]}-#{split_file_path[1]}"
  end

  def scheme_id(filename)
    split_file_path = filename.split('-')
    split_id = split_file_path[2].split('.')
    split_id[0]
  end

  def test_expectation(get_response, response)
    case get_response
    when 200
      expect(response.status).to eq(201)
    when 404
      expect(response.status).to eq(404)
    else
      expect(response.status).to eq(400) # make it fail deliberatly
    end
  end

  def request_get_headers
    client_registered = create(:client)
    {
      'x-api-key' => client_registered.api_key,
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json'
    }
  end

  def request_post_headers
    client_registered = create(:client)
    {
      'x-api-key' => client_registered.api_key,
    }
  end
  # rubocop:disable RSpec/NoExpectationExample
  Dir.each_child('spec/stub_response/api_stubs') do |filename|
    describe 'Test mock services includes salesforce mock' do
      it filename do
        url_arguments = get_params(filename)
        get "/identities/schemes/#{url_arguments[:scheme]}/identifiers/#{url_arguments[:id]}", headers: request_get_headers
        get_response = response.status

        search_params = { identifier: get_params(filename) }
        post '/identities/organisations', params: search_params, headers: request_post_headers

        test_expectation(get_response, response)
      end
    end
  end
  # rubocop:enable RSpec/NoExpectationExample
end
