module CompaniesHouse
  class Search
    def initialize(company_reg_number)
      super()
      @company_reg_number = company_reg_number
      @error = nil
      @result = []
    end

    def fetch_results
      conn = Faraday.new(url: ENV['COMPANIES_HOUSE_API_ENDPOINT'])
      conn.basic_auth("#{ENV['COMPANIES_HOUSE_API_TOKEN']}:", '')
      resp = conn.get("/company/#{@company_reg_number}")

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
        Identifier: indentifier,
        additionalIdentifiers: [],
        address: address,
        contactPoint: contact_point
      }
    end

    def indentifier
      {
        "scheme": 'GB-COH',
        "id": @result['company_number'].present? ? @result['company_number']: @company_reg_number,
        "legalName": @result['company_name'].present? ? @result['company_name']: '',
        "uri": ''
      }
    end

    def name
      @result['company_name']
    end

    def address
      {
        "streetAddress": @result['registered_office_address']['address_line_1'].present? ? @result['registered_office_address']['address_line_1']: '',
        "locality": @result['registered_office_address']['locality'].present? ? @result['registered_office_address']['locality']: '',
        "region": '',
        "postalCode": @result['registered_office_address']['postal_code'].present? ? @result['registered_office_address']['postal_code']: '',
        "countryName": @result['registered_office_address']['country'].present? ? @result['registered_office_address']['country']: ''
      }
    end

    def contact_point
      {
        'name': '',
        'email': '',
        'telephone': '',
        'faxNumber': '',
        'url': ''
      }
    end
  end
end
