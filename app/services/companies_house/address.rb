module CompaniesHouse
  class Address
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        "streetAddress": street_address,
        "locality": locality,
        "region": '',
        "postalCode": postal_code,
        "countryName": country_name
      }
    end

    def street_address
      exists_or_null(@result['registered_office_address']['address_line_1'])
    end

    def locality
      exists_or_null(@result['registered_office_address']['locality'])
    end

    def postal_code
      exists_or_null(@result['registered_office_address']['postal_code'])
    end

    def country_name
      exists_or_null(@result['registered_office_address']['country'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
