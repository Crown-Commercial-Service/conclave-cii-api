module Dnb
  class Indentifier
    def initialize(result)
      super()
      @result = result
    end

    def build_response
      {
        scheme: 'US-DUN',
        id: duns_number,
        legalName: legal_name,
        uri: ''
      }
    end

    def duns_number
      exists_or_null(@result['organization']['duns'])
    end

    def legal_name
      exists_or_null(@result['organization']['primaryName'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
