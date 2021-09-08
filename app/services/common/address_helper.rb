module Common
  class AddressHelper
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
      @result && @result[:address].present? ? exists_or_null(@result[:address][:streetAddress]) : ''
    end

    def locality
      @result && @result[:address].present? ? exists_or_null(@result[:address][:locality]) : ''
    end

    def region
      @result && @result[:address].present? ? exists_or_null(@result[:address][:region]) : ''
    end

    def postal_code
      @result && @result[:address].present? ? exists_or_null(@result[:address][:postalCode]) : ''
    end

    def country_name
      country = @result && @result[:address].present? ? exists_or_null(@result[:address][:countryName]) : ''
      country.present? ? country : ''
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
