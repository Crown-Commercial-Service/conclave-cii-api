module Dnb
  class Search
    def initialize(duns_number, additional_identifier_search = false)
      super()
      @duns_number = duns_number
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
      @additional_identifier_search = additional_identifier_search != false
    end

    def fetch_token
      conn = Faraday.new(url: ENV.fetch('DNB_API_ENDPOINT', nil))
      conn.basic_auth(ENV.fetch('DNB_USERNAME', nil), ENV.fetch('DNB_PASSWORD', nil))
      params = { grant_type: 'client_credentials' }.to_json
      resp = conn.post('/v2/token', params, { 'Content-Type' => 'application/json' })
      ApiLogging::Logger.api_status_error('DNB API| method:fetch_token', resp)
      ApiValidations::ApiErrorValidationResponse.new(resp.status) if @additional_identifier_search == false
      resp.body
    end

    def validate_token
      token = JSON.parse(fetch_token)
      return false if token['access_token'].blank?
    end

    def fetch_results
      validate_token
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('DNB_API_ENDPOINT', nil))
      params = { productId: 'cmptcs', versionId: 'v1' }
      conn.authorization :Bearer, token['access_token']
      resp = conn.get("/v1/data/duns/#{@duns_number}", params)
      logging(resp)
      ApiValidations::ApiErrorValidationResponse.new(resp.status) if @additional_identifier_search == false
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

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
        additionalIdentifiers: filter_additional_indentifiers,
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
      # ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
