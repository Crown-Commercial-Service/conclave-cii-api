module Spotlight
  class Address
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        streetAddress: street_address,
        locality: locality,
        region: '',
        postalCode: postal_code,
        countryName: country_name
      }
    end

    def street_address
      exists_or_null(@result['BillingStreet'])
    end

    def locality
      exists_or_null(@result['BillingCity'])
    end

    def postal_code
      # Temporary tactical fix, until PPG allows empty postcode string. This is scoped for a future sprint.
      exists_or_na(@result['BillingPostalCode'])
    end

    def country_name
      exists_or_null(@result['BillingCountry'])
    end

    private

    def exists_or_na(api_param)
      api_param.present? ? api_param : 'NA'
    end

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
