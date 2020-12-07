module CompaniesHouse
  class Search
    def initialize(company_reg_number)
      super()
      @company_reg_number = company_reg_number
      @error = nil
    end

    def fetch_results
      conn = Faraday.new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT'])
      conn.basic_auth("#{ENV['COMPANIES_HOUSE_API_TOKEN']}:", '')
      resp = conn.get("/company/#{@company_reg_number}")
      body_response = ActiveSupport::JSON.decode(resp.body)

      if resp.status != 200
        false
      else
        body_response
      end
    end
  end
end
