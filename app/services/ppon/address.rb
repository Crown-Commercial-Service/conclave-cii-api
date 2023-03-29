module Ppon
  class Address
    def build_response
      {
        streetAddress: '',
        locality: '',
        region: '',
        postalCode: '',
        countryName: ''
      }
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
