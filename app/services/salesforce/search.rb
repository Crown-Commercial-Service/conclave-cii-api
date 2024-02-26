module Salesforce
  class Search
    def initialize(id_number, scheme_id, additional_identifier_search = false)
      super()
      @id_number = id_number # support only for duns or companies house number
      @scheme_id = scheme_id
      @error = nil
      @result = []
      @sf_status = nil
      @additional_identifier_search = additional_identifier_search != false
    end

    def post_params
      {
        'username' => ENV.fetch('SALESFORCE_USERNAME', nil),
        'password' => ENV.fetch('SALESFORCE_PASSWORD', nil) + ENV.fetch('SALESFORCE_SECURITY_TOKEN', nil),
        'grant_type' => 'password',
        'client_id' => ENV.fetch('SALESFORCE_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('SALESFORCE_CLIENT_SECRET', nil)
      }
    end

    def fetch_token
      conn = Faraday.new(url: ENV.fetch('SALESFORCE_AUTH_URL', nil))
      params = post_params
      resp = conn.post('/services/oauth2/token', params, { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ApiLogging::Logger.api_status_error('Salesforce method:fetch_token', resp)
      resp.body
    end

    def fetch_results
      fetch_results_from_api
    rescue StandardError => e
      ApiLogging::Logger.fatal("SALESFORCE API| method:fetch_results, #{e.to_json}")
      ApiValidations::ApiErrorValidationResponse.new(503) if @additional_identifier_search == false
    end

    def fetch_results_from_api
      false if build_arguments.blank?

      token = JSON.parse(fetch_token)
      url = "/services/data/v45.0/query?q=SELECT+ID,name,Status__c,Supplier_DUNS_Number__c,Company_Registration_Number__c,Account_URN__c+FROM+account+WHERE+#{build_arguments}"
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('SALESFORCE_AUTH_URL', nil), request: { params_encoder: Faraday::FlatParamsEncoder })
      conn.authorization :Bearer, token['access_token']
      resp = conn.get(url)
      ApiLogging::Logger.api_status_error('Salesforce method:fetch_results', resp)
      @sf_status = resp.status
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && Common::ApiHelper.exists_or_null(@result['records'][0]).present?
        response_payload
      else
        false
      end
    end

    def response_payload
      {
        scheme: Common::AdditionalIdentifier::SCHEME_CCS,
        id: salesforce_scheme_id,
        legalName: legal_name,
        uri: uri,
      }
    end

    def build_arguments
      case @scheme_id
      when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
        companies_house_number
      when Common::AdditionalIdentifier::SCHEME_DANDB
        duns_number
      when Common::AdditionalIdentifier::SCHEME_CCS
        salesforce_account_number
      end
    end

    def duns_number
      "Supplier_DUNS_Number__c='#{@id_number}'"
    end

    def companies_house_number
      "Company_Registration_Number__c='#{@id_number}'"
    end

    def salesforce_account_number
      "Account_URN__c='#{@id_number}'"
    end

    def salesforce_scheme_id
      "#{@result['records'][0]['Id']}~#{@result['records'][0]['Account_URN__c']}"
    end

    def legal_name
      if Common::ApiHelper.exists_or_null(@result['records'][0]['Name']).present?
        @result['records'][0]['Name']
      else
        ''
      end
    end

    def uri
      if Common::ApiHelper.exists_or_null(@result['records'][0]['attributes']['url']).present?
        @result['records'][0]['attributes']['url']
      else
        ''
      end
    end
  end
end
