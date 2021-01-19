module FindThatCharity
  class Identifier
    def initialize(scheme_id, result)
      super()
      @scheme_id = scheme_id
      @result = result
    end

    def build_response
      {
        'scheme': @scheme_id,
        'id': id,
        'legalName': legal_name,
        'uri': uri
      }
    end

    def id
      exists_or_null(@result['charityNumber'])
    end

    def legal_name
      exists_or_null(@result['name'])
    end

    def uri
      exists_or_null(@result['url'])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
