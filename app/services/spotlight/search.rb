module Spotlight
  class Search
    def initialize(id_number, scheme_id, additional_identifier_search = false)
      super()
      @id_number = id_number
      @scheme_id = scheme_id
      @company_number = nil
      @error = nil
      @result = []
      @additional_indentifers_list = []
      @additional_identifier_search = additional_identifier_search != false
    end

    def post_params
      {
        'username' => ENV.fetch('CONFIG_SPOTLIGHT_USERNAME', nil),
        'password' => ENV.fetch('CONFIG_SPOTLIGHT_PASSWORD', nil),
        'grant_type' => 'password',
        'client_id' => ENV.fetch('CONFIG_SPOTLIGHT_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('CONFIG_SPOTLIGHT_CLIENT_SECRET', nil)
      }
    end

    def fetch_token
      conn = Faraday.new(url: ENV.fetch('CONFIG_SPOTLIGHT_AUTH_URL', nil))
      params = post_params
      resp = conn.post('/services/oauth2/token', params, { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ApiLogging::Logger.api_status_error('Salesforce method:fetch_token', resp)
      resp.body
    end

    def fetch_results
      fetch_results_from_api
    rescue StandardError => e
      ApiLogging::Logger.fatal("SPOTLIGHT API| method:fetch_results, #{e.to_json}")
      ApiValidations::ApiErrorValidationResponse.new(503) if @additional_identifier_search == false
    end

    def fetch_results_from_api # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      token = JSON.parse(fetch_token)

      return false if token['access_token'].blank?

      resp = search_results(token)
      logging(resp)
      return false if resp.body.include?('Non 200/206 code received from D and B')

      ApiValidations::ApiErrorValidationResponse.new(resp.status) if @additional_identifier_search == false
      decoded_result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200
      @result = decoded_result['searchOrganisation'][0]

      if resp.status == 200 && @result.key?('Status') && @result['Status'] == 'Active'
        build_response
      else
        false
      end
    end

    def search_results(token)
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('CONFIG_SPOTLIGHT_AUTH_URL', nil))
      conn.authorization :Bearer, token['access_token']

      conn.get('/services/apexrest/searchorganisation') do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Content-Type'] = 'application/json'
        req.headers['payload'] = build_arguments.to_json
      end
    end

    def build_response
      {
        name: name,
        identifier: Spotlight::Indentifier.new(@result).build_response,
        additionalIdentifiers: additional_identifiers,
        address: Spotlight::Address.new(@result).build_response,
        contactPoint: Spotlight::Contact.new(@result).build_response
      }
    end

    def additional_identifiers
      additional_identifiers_list = []
      additional_identifiers_list << SearchApiAdditionalIdentifiers.new(@result['CompaniesHouseNumber'], Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE).call if Common::ApiHelper.exists_or_null(@result['CompaniesHouseNumber']).present?
      additional_identifiers_list << SearchApiAdditionalIdentifiers.new(@result['CharityCommissionforEnglandandWales'], Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY).call if Common::ApiHelper.exists_or_null(@result['CharityCommissionforEnglandandWales']).present?
      additional_identifiers_list << SearchApiAdditionalIdentifiers.new(@result['CharityCommissionforNorthernIreland'], Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY).call if Common::ApiHelper.exists_or_null(@result['CharityCommissionforNorthernIreland']).present?
      additional_identifiers_list
    end

    def name
      exists_or_null(@result['Name'])
    end

    def build_arguments
      case @scheme_id
      when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
        companies_house_number
      when Common::AdditionalIdentifier::SCHEME_DANDB
        duns_number
      end
    end

    def duns_number
      {
        requestType: 'SearchOrganisation',
        parameters: {
          dunsNumber: @id_number
        }
      }
    end

    def companies_house_number
      {
        requestType: 'SearchOrganisation',
        parameters: {
          companiesHouseNumber: @id_number,
          country: 'GB'
        }
      }
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    rescue StandardError => e
      ApiLogging::Logger.info(e)
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('SPOTLIGHT DNB API| method:fetch_results', resp)
      # ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
