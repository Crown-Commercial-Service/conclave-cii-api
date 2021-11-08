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
      conn = Common::ApiHelper.faraday_new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT'])
      conn.basic_auth("#{ENV['COMPANIES_HOUSE_API_TOKEN']}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
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
        identifier: CompaniesHouse::Indentifier.new(@result).build_response,
        additionalIdentifiers: [],
        address: CompaniesHouse::Address.new(@result).build_response,
        contactPoint: CompaniesHouse::Contact.new(@result).build_response
      }
    end

    def name
      @result['company_name']
    end

    def logging(resp)
      ApiLogging::Logger.api_status_error('Companies House API | method:fetch_results', resp)
      ApiLogging::Logger.info(resp.headers['X-RateLimit-Remain'])
    end
  end
end
