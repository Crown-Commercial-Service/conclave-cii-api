module Dnb
  class Search
    def initialize(duns_number)
      super()
      @duns_number = duns_number
      @error = nil
    end

    def fetch_token
      conn = Faraday.new(url: ENV['DNB_API_ENDPOINT'])
      conn.basic_auth(ENV['DNB_USERNAME'], ENV['DNB_PASSWORD'])
      params = { 'grant_type': 'client_credentials' }.to_json
      resp = conn.post('/v2/token', params, { 'Content-Type' => 'application/json' })
      resp.body
    end

    def fetch_results
      token = JSON.parse(fetch_token)
      conn = Faraday.new(url: ENV['DNB_API_ENDPOINT'])
      params = { 'productId': 'cmptcs', 'versionId': 'v1', 'orderReason': '6333' }
      conn.authorization :Bearer, token['access_token']
      resp = conn.get("/v1/data/duns/#{@duns_number}", params)
      resp.body
    end
  end
end
