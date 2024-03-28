module MockingService
  class ApiSpotlightStub
    include WebMock::API

    def initialize(params)
      @params = params
      @result = nil
      @api_url = nil
      stub
    end

    def stub
      load_stub
      stub_request
    end

    def stub_request
      WebMock.stub_request(:get, url)
             .with(headers: stub_headers)
             .to_return(status: http_status, body: @result, headers: {})
    end

    def stub_headers
      {
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v1.10.3'
      }
    end

    def stub_token_headers
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Faraday v1.10.3'
      }
    end

    def http_status
      '404' unless @result.nil?
      '200' if @result.blank?
    end

    def url
      spotlight_token
      @api_url = "#{ENV.fetch('SPOTLIGHT_AUTH_URL', nil)}/services/apexrest/searchorganisation"
    end

    def spotlight_token
      token_response = File.read('spec/stub_response/tokens/spotlight_token.json')
      spotlight = Spotlight::Search.new(@params[:id], @params[:scheme])
      spotlight.post_params.inspect
      WebMock.stub_request(:post, "#{ENV.fetch('SPOTLIGHT_AUTH_URL', nil)}/services/oauth2/token")
             .with(
               body: spotlight.post_params,
               headers: stub_token_headers
             )
             .to_return(status: 200, body: token_response, headers: {})
    end

    def load_stub
      @result = File.read("spec/stub_response/spotlight/#{@params[:scheme]}-#{@params[:id]}.json")
    rescue StandardError
      {}
    end
  end
end
