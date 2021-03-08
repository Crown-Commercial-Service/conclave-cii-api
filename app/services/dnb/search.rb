module Dnb
  class Search
    def initialize(duns_number)
      super()
      @duns_number = duns_number
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_token
      conn = Faraday.new(url: ENV['DNB_API_ENDPOINT'])
      conn.basic_auth(ENV['DNB_USERNAME'], ENV['DNB_PASSWORD'])
      params = { grant_type: 'client_credentials' }.to_json
      resp = conn.post('/v2/token', params, { 'Content-Type' => 'application/json' })
      resp.body
    end

    def fetch_results
      token = JSON.parse(fetch_token)
      conn = Faraday.new(url: ENV['DNB_API_ENDPOINT'])
      params = { productId: 'cmptcs', versionId: 'v1' }
      conn.authorization :Bearer, token['access_token']
      resp = conn.get("/v1/data/duns/#{@duns_number}", params)
      @result = ActiveSupport::JSON.decode(resp.body)

      if resp.status == 200 && @result.key?('organization') && @result['organization']['dunsControlStatus']['operatingStatus']['dnbCode'] == 9074
        build_response
      else
        false
      end
    end

    def build_response
      {
        name: name,
        identifier: Dnb::Indentifier.new(@result).build_response,
        additionalIdentifiers: filter_additional_indentifers,
        address: Dnb::Address.new(@result).build_response,
        contactPoint: Dnb::Contact.new(@result).build_response
      }
    end

    def additional_identifiers
      additional_identifiers_links if Common::ApiHelper.exists_or_null(@result['organization']['registrationNumbers']).present?
    end

    def additional_identifiers_links
      @additional_indentifers_list.concat(Common::AdditionalIdentifier.new.filter_dandb_ids(@result['organization']['registrationNumbers'], @duns_number))
    end

    def filter_additional_indentifers
      additional_identifiers
      @additional_indentifers_list.uniq { |identifier| identifier[:id] }
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
