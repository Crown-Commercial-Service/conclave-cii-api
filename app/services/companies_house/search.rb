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

      if resp.status == 200
        @result = ActiveSupport::JSON.decode(resp.body)
        return 'Not_Active' if @result.key?('primaryTopic') && @result['primaryTopic']['CompanyStatus'] == false
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

    def name
      @result['company_name']
    end
  end
end
