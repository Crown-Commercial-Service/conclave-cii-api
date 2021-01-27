module Dnb
  class Search
    def initialize(duns_number)
      super()
      @duns_number = duns_number
      @company_number = nil
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

      if resp.status == 200
        build_response
      else
        false
      end
    end

    def build_response
      {
        name: name,
        identifier: Dnb::Indentifier.new(@result).build_response,
        additionalIdentifiers: registration_numbers,
        address: Dnb::Address.new(@result).build_response,
        contactPoint: Dnb::Contact.new(@result).build_response
      }
    end

    def registration_numbers
      [] if exists_or_null(@result['organization']['registrationNumbers']).blank?
      Dnb::AdditionalIdentifier.new(@result['organization']['registrationNumbers']).build_response
    end

    def name
      exists_or_null(@result['organization']['primaryName'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.warning(e)
    end
  end
end
