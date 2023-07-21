module Dnb
  class AdditionalIdentifier
    def initialize(duns_number)
      super()
      @duns_number = duns_number
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
      duns_api = Dnb::Search.new(@duns_number, true)
      duns_api.fetch_results
    end
  end
end
