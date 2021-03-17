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
      conn = Faraday.new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT'])
      conn.basic_auth("#{ENV['COMPANIES_HOUSE_API_TOKEN']}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
      api_status_error(resp)
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
        additionalIdentifiers: [],
        address: CompaniesHouse::Address.new(@result).build_response,
        contactPoint: CompaniesHouse::Contact.new(@result).build_response
      }
    end

    def api_status_error(resp)
      ApiLogging::Logger.warning("Companies house 403 ERROR #{resp.to_json}") if resp.status == 403
      ApiLogging::Logger.warning("Companies house 401 ERROR #{resp.to_json}") if resp.status == 401
    end

    def name
      @result['company_name']
    end
  end
end
