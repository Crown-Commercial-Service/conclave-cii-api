module RegistryUpdate
  class OrganisationAddress
    def initialize(registry_result)
      @registry_result = registry_result
    end

    def address_payload
      {
        address: {
          streetAddress: street_address,
          locality: locality,
          region: region,
          postalCode: postal_code,
          countryName: country_name
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
