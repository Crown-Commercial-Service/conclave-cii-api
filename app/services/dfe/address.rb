module Dfe
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
      exists_or_null(@result['Address']['Street'])
    end

    def locality
      exists_or_null(@result['Address']['Locality'])
    end

    def region
      exists_or_null(@result['Address']['Town'])
    end

    def postal_code
      # Temporary tactical fix, until PPG allows empty postcode string. This is scoped for a future sprint.
      api_param = @result['Address']['Postcode']

      api_param.present? ? api_param : 'NA'
    end

    def country_name
      return 'United Kingdom' unless @result['RscRegion']['Name'].present?

      if @result['RscRegion']['Name'].include? 'England'
        'England'
      elsif @result['RscRegion']['Name'].include? 'Wales'
        'Wales'
      elsif @result['RscRegion']['Name'].include? 'Ireland'
        'Northern Ireland'
      elsif @result['RscRegion']['Name'].include? 'Scotland'
        'Scotland'
      else
        'United Kingdom'
      end
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
