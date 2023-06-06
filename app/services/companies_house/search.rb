module CompaniesHouse
  class Search
    def initialize(company_reg_number)
      super()
      @company_reg_number = company_reg_number
      @error = nil
      @result = []
      @additional_indentifers_list = []
    end

    def fetch_results
      conn = Common::ApiHelper.faraday_new(url: ENV.fetch('COMPANIES_HOUSE_API_ENDPOINT', nil))
      conn.basic_auth("#{ENV.fetch('COMPANIES_HOUSE_API_TOKEN', nil)}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
      puts resp.inspect 
      logging(resp)
      @result = ActiveSupport::JSON.decode(resp.body) if resp.status == 200

      if resp.status == 200 && @result.key?('company_status') && @result['company_status'] == 'active'
        build_response
      else
        false
      end
    end

    private

    def build_response
      {
        name: name,
        identifier: CompaniesHouse::Indentifier.new(@result).build_response,
        additionalIdentifiers: additional_identifier_duns,
        address: CompaniesHouse::Address.new(@result).build_response,
        contactPoint: CompaniesHouse::Contact.new(@result).build_response
      }
    end

    def name
      @result['company_name']
    end

    def additional_identifier_duns
      duns_search = DnbChn::AdditionalIdentifier.new(@company_reg_number).build_response

      if duns_search.present?
        [duns_search]
      else
        []
      end
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('Companies House API | method:fetch_results', resp)
      ApiLogging::Logger.info("Companies House API | Rate Limit remaining: #{resp.headers['x-ratelimit-remain']}")
    end
  end
end
