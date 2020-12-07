module FindThatCharity
  class Search
    def initialize(charity_number)
      super()
      @charity_number = charity_number
      @error = nil
    end

    def fetch_results
      conn = Faraday.new(url: ENV['FINDTHATCHARITY_API_ENDPOINT'])
      resp = conn.get("/charity/#{@charity_number}.json")

      if resp.status != 200
        false
      else
        resp.body
      end
    end
  end
end
