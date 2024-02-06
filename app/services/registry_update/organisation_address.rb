module RegistryUpdate
  class OrganisationAddress
    def initialize(registry_result)
      @registry_result = registry_result
    end

    def address_payload
      {
        address: {
          streetAddress: street_address.blank? ? '38 CII, LONDON' : street_address,
          locality: locality.blank? ? 'cii-locality' : locality,
          region: region.blank? ? 'london' : region,
          postalCode: postal_code.blank? ? 'N15 5ER' : postal_code,
          countryName: country_name.blank? ? 'United Kingdom' : country_name
        }
      }
    end

    def street_address
      exists_or_null(@registry_result[:address][:streetAddress])
    end

    def locality
      exists_or_null(@registry_result[:address][:locality])
    end

    def region
      exists_or_null(@registry_result[:address][:region])
    end

    def postal_code
      exists_or_null(@registry_result[:address][:postalCode])
    end

    def country_name
      exists_or_null(@registry_result[:address][:countryName])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
