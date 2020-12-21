module Dnb
  class Search
    def initialize(duns_number)
      super()
      @duns_number = duns_number
      @error = nil
      @result = []
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
      params = { 'productId': 'cmptcs', 'versionId': 'v1' }
      conn.authorization :Bearer, token['access_token']
      resp = conn.get("/v1/data/duns/#{@duns_number}", params)
      @result = ActiveSupport::JSON.decode(resp.body)

      if resp.status != 200
        false
      else
        build_response
      end
    end

    def build_response
      {
        name: name,
        Identifier: indentifier,
        additionalIdentifiers: {
          # schemes: additional_identifiers,
          companies_house: compnaies_house
        },
        address: address
      }
    end

    def indentifier
      {
        "scheme": 'US-DUN',
        "id": @result['organization']['duns'],
        "legalName": @result['organization']['registeredName'],
        "uri": ''
      }
    end

    def name
      @result['organization']['primaryName']
    end

    def address
      {
        "streetAddress": "#{@result['organization']['primaryAddress']['streetAddress']['line1']} #{@result['organization']['primaryAddress']['streetAddress']['line2']}",
        "locality": @result['organization']['primaryAddress']['addressLocality']['name'],
        "region": '',
        "postalCode": @result['organization']['primaryAddress']['postalCode'],
        "countryName": @result['organization']['primaryAddress']['addressCountry']['name']
      }
    end

    def additional_identifiers
      {
        "scheme": 'GB-COH',
        "id": @result['organization']['registrationNumbers'][0]['registrationNumber'],
        "legalName": @result['organization']['registeredName'],
        "uri": ''
      }
    end

    def compnaies_house
      company_api = CompaniesHouse::Search.new(@result['organization']['registrationNumbers'][0]['registrationNumber'])
      company_api.fetch_results
    end
  end
end
