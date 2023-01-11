module Dfe
  class Indentifier
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        scheme: 'GB-DFE',
        id: organisation_code,
        legalName: legal_name,
        uri: url
      }
    end

    def organisation_code
      exists_or_null(@result['Urn'])
    end

    def legal_name
      exists_or_null(@result['Establishment']['Name'])
    end

    def url
      exists_or_null(@result['SchoolWebsite'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
