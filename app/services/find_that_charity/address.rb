module FindThatCharity
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
        countryName: country_name # Need to be verified and agreed but charity is not correct
      }
    end

    def street_address
      exists_or_null(@result['address']['streetAddress'])
    end

    def locality
      exists_or_null(@result['address']['addressLocality'])
    end

    def region
      exists_or_null(@result['address']['addressRegion'])
    end

    def postal_code
      exists_or_null(@result['address']['postalCode'])
    end

    def country_name
      country = exists_or_null(@result['address']['addressCountry'])
      country.present? ? country : ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
