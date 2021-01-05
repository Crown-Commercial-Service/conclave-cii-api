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
      @result = ActiveSupport::JSON.decode(resp.body)
      if resp.status == 200
        build_response
      else
        false
      end
    end

    private

    def build_response
      {
        name: name,
        Identifier: indentifier,
        address: address
      }
    end

    def indentifier
      {
        'scheme': 'GB-CHC',
        'id': @result['data']['CHC']['getCharities']['list']['id'],
        'legalName': @result['data']['CHC']['getCharities']['list']['name'].select { |list| list['primary'] == true },
        'uri': ''
      }
    end

    def name
      @result['data']['CHC']['getCharities']['list']['name'].select { |list| list['primary'] == true }
    end

    def address
      {
        'streetAddress': @result['data']['CHC']['getCharities']['list']['contact']['adress'][0],
        'locality': '',
        'region': '',
        'postalCode': @result['data']['CHC']['getCharities']['list']['contact']['adress']['postcode'],
        'countryName': ''
      }
    end
  end
end
