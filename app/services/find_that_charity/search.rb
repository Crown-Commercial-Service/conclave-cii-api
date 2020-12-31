module FindThatCharity
  class Search
    def initialize(charity_number, scheme_id)
      super()
      @charity_number = charity_number
      @scheme_id = scheme_id
      @error = nil
      @result = []
    end

    def fetch_results
      conn = Faraday.new(url: ENV['FINDTHATCHARITY_API_ENDPOINT'])
      resp = conn.get("/orgid/#{@scheme_id}-#{@charity_number}.json")
      resp.inspect
      if resp.status != 200
        false
      else
        @result = ActiveSupport::JSON.decode(resp.body)
        build_response
      end
    end

    private

    def build_response
      {
        name: name,
        Identifier: FindThatCharity::Identifier.new(@scheme_id, @result).build_response,
        additionalIdentifiers: [
          CompaniesHouse::AdditionalIndentifier.new(@result['companyNumber']).build_response
        ],
        address: FindThatCharity::Address.new(@result).build_response,
        contactPoint: FindThatCharity::Contact.new(@result).build_response
      }
    end

    def name
      @result['name'] = @result['name'].present? ? @result['name'] : ''
    end
  end
end
