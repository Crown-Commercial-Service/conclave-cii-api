module FindThatCharity
  class Search
    def initialize(charity_number, scheme_id)
      super()
      @charity_number = charity_number
      @scheme_id = scheme_id
      @error = nil
      @result = []
      @pay_load = {}
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
        Identifier: indentifier,
        additionalIdentifiers: [
          additional_identifiers_companies_house
        ],
        address: address,
        contactPoint: contact_point
      }
    end

    def indentifier
      {
        'scheme': @scheme_id,
        'id': @result['id'].present? ? @result['id'] : '',
        'legalName': @result['name'].present? ? @result['name'] : '',
        'uri': @result['url'].present? ? @result['url'] : ''
      }
    end

    def name
      @result['name'] = @result['name'].present? ? @result['name'] : ''
    end

    def address
      {
        'streetAddress': @result['address']['streetAddress'].present? ? @result['address']['streetAddress'] : '',
        'locality': @result['address']['addressLocality'].present? ? @result['address']['addressLocality'] : '',
        'region': @result['address']['addressRegion'].present?   ? @result['address']['addressRegion'] : '',
        'postalCode': @result['address']['postalCode'].present? ? @result['address']['postalCode'] : '',
        'countryName': 'UK' # Need to be verified and agreed but charity is not correct
      }
    end

    def additional_identifiers_companies_house
      search_result = @result['companyNumber'].present? ? compnaies_house_api(@result['companyNumber']) : ''
      return if search_result.include?('name')

      {
        'scheme': 'GB-COH',
        'id': @result['companyNumber'].present? ? @result['companyNumber'] : '',
        'legalName': search_result[:name].present? ? search_result[:name] : '',
        'uri': search_result[:Identifier][:uri].present? ? search_result[:Identifier][:uri] : '',
      }
    end

    def contact_point
      {
        'name': '',
        'email': @result['email'].present? ? @result['email'] : '',
        'telephone': @result['telephone'].present? ? @result['telephone'] : '',
        'faxNumber': '',
        'url': @result['url'].present? ? @result['url'] : ''
      }
    end

    def compnaies_house_api(company_reg_number)
      company_api = CompaniesHouse::Search.new(company_reg_number)
      company_api.fetch_results
    end
  end
end
