module Nhs
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
      "#{exists_or_null(@result['Organisation']['GeoLoc']['Location']['AddrLn1'])}#{street_address_two}#{street_address_three}"
    end

    def street_address_two
      ", #{exists_or_null(@result['Organisation']['GeoLoc']['Location']['AddrLn2'])}" if exists_or_null(@result['Organisation']['GeoLoc']['Location']['AddrLn2']).present?
    end

    def street_address_three
      ", #{exists_or_null(@result['Organisation']['GeoLoc']['Location']['AddrLn3'])}" if exists_or_null(@result['Organisation']['GeoLoc']['Location']['AddrLn3']).present?
    end

    def locality
      exists_or_null(@result['Organisation']['GeoLoc']['Location']['Town'])
    end

    def region
      exists_or_null(@result['Organisation']['GeoLoc']['Location']['County'])
    end

    def postal_code
      exists_or_null(@result['Organisation']['GeoLoc']['Location']['PostCode'])
    end

    def country_name
      exists_or_null(@result['Organisation']['GeoLoc']['Location']['Country'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
