module Charitybase
  class Search
    def initialize(charity_number)
      super()
      @charity_number = charity_number
      @error = nil
    end

    def graphql_query
      <<~HEREDOC
        {
          CHC
              {
                getCharities(filters: {
                  id:#{@charity_number}
                })
                {
                  count
                  list(limit: 3)
                {
                  id
                  names
                {
                  value
                  primary
                }
                contact {
                    email
                    phone
                    address
                    postcode
                  }
                orgIds {
                        id
                        rawId
                        scheme
                      }
                 activities
                }
              }
            }
          }
      HEREDOC
    end

    def fetch_results
      conn = Faraday.new(url: ENV['CHARITYBASE_API_ENDPOINT'])
      resp = conn.get('/api/graphql') do |req|
        req.params['limit'] = 100
        req.headers['Authorization'] = "Apikey #{ENV['CHARITYBASE_API_TOKEN']}"
        req.headers['Content-Type'] = 'application/json'
        req.body = { query: graphql_query }.to_json
      end
      resp.body
    end
  end
end
