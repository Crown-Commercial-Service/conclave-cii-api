module Spotlight
  class AdditionalIdentifier
    def initialize(duns_number, scheme_id)
      super()
      @duns_number = duns_number
      @scheme_id = scheme_id
      @search_result = []
    end

    def build_response
      @search_result = @duns_number.present? ? search_duns_api : false
      response_payload if @search_result
    end

    def response_payload
      @search_result[:identifier]
    end

    private

    def search_duns_api
      duns_api = Spotlight::Search.new(@duns_number, @scheme_id, true)
      duns_api.fetch_results
    end
  end
end
