module DnbChn
  class Search
    def initialize(company_reg_number)
      super()
      @company_reg_number = company_reg_number
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_token
      conn = Faraday.new(url: ENV.fetch('DNB_API_ENDPOINT', nil))
      conn.basic_auth(ENV.fetch('DNB_USERNAME', nil), ENV.fetch('DNB_PASSWORD', nil))
      params = { grant_type: 'client_credentials' }.to_json
      resp = conn.post('/v2/token', params, { 'Content-Type' => 'application/json' })
      ApiLogging::Logger.api_status_error('DNB API| method:fetch_token', resp)
      resp.body
    end

    def fetch_results
      token = JSON.parse(fetch_token)
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('DNB_API_ENDPOINT', nil))
      conn.authorization :Bearer, token['access_token']
      params = { registrationNumber: @company_reg_number, countryISOAlpha2Code: 'GB' }
      resp = conn.get('/v1/match/cleanseMatch', params)
      logging(resp)
      @result = res_init(resp)
      if resp.status == 200 && @result.key?('organization') && @result['organization']['dunsControlStatus']['operatingStatus']['description'] == "Active"
        build_response
      else
        false
      end
    end

    def build_response
      {
        name: name,
        identifier: DnbChn::Indentifier.new(@result).build_response,
        additionalIdentifiers: filter_additional_indentifiers,
        address: DnbChn::Address.new(@result).build_response,
        contactPoint: DnbChn::Contact.new(@result).build_response
      }
    end

    def additional_identifiers
      additional_identifiers_links if Common::ApiHelper.exists_or_null(@result['organization']['registrationNumbers']).present?
    end

    def additional_identifiers_links
      @additional_indentifers_list.concat(Common::AdditionalIdentifier.new.filter_dandb_ids(@result['organization']['registrationNumbers'], @company_reg_number))
    end

    def filter_additional_indentifiers
      additional_identifiers
      @additional_indentifers_list.uniq { |identifier| identifier[:id] }
    end

    def name
      exists_or_null(@result&.dig('organization', 'primaryName'))
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.info(e)
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('DNB API| method:fetch_results', resp)
      ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end

    def res_init(api_response)
      result_resp = ActiveSupport::JSON.decode(api_response.body) if api_response.status == 200
      result_resp['matchCandidates'][0]
    end
  end
end
