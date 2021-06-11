module Salesforce
  class Search
    def initialize(id_number, scheme_id)
      super()
      @id_number = id_number # support only for duns or companies house number
      @scheme_id = scheme_id
      @error = nil
      @result = []
    end

    def post_params
      {
        'username' => ENV['SALESFORCE_USERNAME'],
        'password' => ENV['SALESFORCE_PASSWORD'] + ENV['SALESFORCE_SECURITY_TOKEN'],
        'grant_type' => 'password',
        'client_id' => ENV['SALESFORCE_CLIENT_ID'],
        'client_secret' => ENV['SALESFORCE_CLIENT_SECRET']
      }
    end

    def fetch_token
      conn = Faraday.new(url: ENV['SALESFORCE_AUTH_URL'])
      params = post_params
      resp = conn.post('/services/oauth2/token', params, { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ApiLogging::Logger.api_status_error('Salesforce method:fetch_token', resp)
      resp.body
    end

    def fetch_results
      false if build_arguments.blank?

      token = JSON.parse(fetch_token)
      url = "/services/data/v45.0/query?q=SELECT+ID,name,Status__c,Supplier_DUNS_Number__c,Company_Registration_Number__c,Account_URN__c+FROM+account+WHERE+#{build_arguments}"
      conn = Faraday.new(url: ENV['SALESFORCE_AUTH_URL'], request: { params_encoder: Faraday::FlatParamsEncoder })
      conn.authorization :Bearer, token['access_token']
      resp = conn.get(url)
      ApiLogging::Logger.api_status_error('Salesforce method:fetch_results', resp)
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
      end
    end

    def duns_number
      "Supplier_DUNS_Number__c='#{@id_number}'"
    end

    def companies_house_number
      "Company_Registration_Number__c='#{@id_number}'"
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
