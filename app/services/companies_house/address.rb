module CompaniesHouse
  class Address
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        streetAddress: street_address,
        locality: locality,
        region: region,
        postalCode: postal_code,
        countryName: country_name
      }
    end

    def street_address
      "#{exists_or_null(@result&.dig('registered_office_address', 'address_line_1'))}#{street_address_two}"
    end

    def street_address_two
      ", #{exists_or_null(@result&.dig('registered_office_address', 'address_line_2'))}" if exists_or_null(@result&.dig('registered_office_address', 'address_line_2')).present?
    end

    def locality
      exists_or_null(@result&.dig('registered_office_address', 'locality'))
    end

    def postal_code
      api_param = exists_or_null(@result&.dig('registered_office_address', 'postal_code'))

      # Temporary tactical fix, until PPG allows empty postcode string. This is scoped for a future sprint.
      api_param.present? ? api_param : 'NA'
    end

    def region
      exists_or_null(@result&.dig('registered_office_address', 'region'))
    end

    def country_name
      country = exists_or_null(@result&.dig('registered_office_address', 'country'))
      country.present? ? country : ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
