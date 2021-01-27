module FindThatCharity
  class AdditionalIdentifier
    def initialize(charity_number, scheme)
      super()
      @charity_number = charity_number
      @scheme = scheme
      @search_result = []
    end

    def build_response
      @search_result = @charity_number.present? ? find_that_charity : false
      response_payload if @search_result
    end

    def response_payload
      {
        'scheme': scheme_code,
        'id': charity_number,
        'legalName': legal_name,
        'uri': uri,
      }
    end

    def scheme_code
      exists_or_null(@scheme)
    end

    def charity_number
      exists_or_null(@charity_number)
    end

    def legal_name
      exists_or_null(@search_result[:name])
    end

    def uri
      exists_or_null(@search_result[:url])
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end

    def find_that_charity
      charity_api = FindThatCharity::Search.new(@charity_number, @scheme)
      charity_api.fetch_results
    end
  end
end
