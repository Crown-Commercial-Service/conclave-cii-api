module Dnb
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
      "#{exists_or_null(@result['organization']['primaryAddress']['streetAddress']['line1'])}#{street_address_two}"
    end

    def street_address_two
      ", #{exists_or_null(@result['organization']['primaryAddress']['streetAddress']['line2'])}" if exists_or_null(@result['organization']['primaryAddress']['streetAddress']['line2']).present?
    end

    def locality
      exists_or_null(@result['organization']['primaryAddress']['addressLocality']['name'])
    end

    def postal_code
      exists_or_null(@result['organization']['primaryAddress']['postalCode'])
    end

    def country_name
      exists_or_null(@result['organization']['primaryAddress']['addressCountry']['name'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
