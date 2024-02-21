module RegistryUpdate
  class UserContact
    def initialize(registry_result)
      @registry_result = registry_result
    end

    def contact_payload
      {
        contactPointName: name,
        contacts: [
          {
            contactType: 'EMAIL',
            contactValue: email
          },
          {
            contactType: 'PHONE',
            contactValue: phone
          },
          {
            contactType: 'FAX',
            contactValue: fax
          },
          {
            contactType: 'WEB_ADDRESS',
            contactValue: web_address
          }
        ]
      }
    end

    def email
      exists_or_null(@registry_result[:contactPoint][:email])
    end

    def phone
      exists_or_null(@registry_result[:contactPoint][:telephone])
    end

    def fax
      exists_or_null(@registry_result[:contactPoint][:faxNumber])
    end

    def web_address
      exists_or_null(@registry_result[:contactPoint][:uri])
    end

    def name
      exists_or_null(@registry_result[:contactPoint][:name])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
