module Nhs
  class Indentifier
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        scheme: 'GB-NHS',
        id: organisation_code,
        legalName: legal_name,
        uri: "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations/#{organisation_code}"
      }
    end

    def organisation_code
      exists_or_null(@result['Organisation']['OrgId']['extension'])
    end

    def legal_name
      exists_or_null(@result['Organisation']['Name'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
