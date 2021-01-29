module FindThatCharity
  class Search
    def initialize(charity_number, scheme_id)
      super()
      @charity_number = Common::ApiHelper.remove_nic(charity_number)
      @scheme_id = scheme_id
      @error = nil
      @result = []
    end

    def fetch_results
      conn = Faraday.new(url: ENV['FINDTHATCHARITY_API_ENDPOINT'])
      resp = conn.get("/orgid/#{@scheme_id}-#{@charity_number}.json")
      if resp.status == 200
        @result = ActiveSupport::JSON.decode(resp.body)
        build_response
      else
        false
      end
    end

    private

    def build_response
      {
        name: name,
        identifier: FindThatCharity::Identifier.new(@scheme_id, @result).build_response,
        additionalIdentifiers: registration_numbers,
        address: FindThatCharity::Address.new(@result).build_response,
        contactPoint: FindThatCharity::Contact.new(@result).build_response
      }
    end

    def registration_numbers
      if Common::ApiHelper.exists_or_null(@result['companyNumber']).blank?
        []
      else
        search_companies_house
      end
    end

    def search_companies_house
      [CompaniesHouse::AdditionalIdentifier.new(@result['companyNumber']).build_response]
    end

    def name
      @result['name'] = @result['name'].present? ? @result['name'] : ''
    end
  end
end
