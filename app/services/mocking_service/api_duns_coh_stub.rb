module MockingService
  class ApiDunsCohStub
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
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v1.3.0'
      }
    end

    def stub_token_headers
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Faraday v1.3.0'
      }
    end

    def http_status
      '404' unless @result.nil?
      '200' if @result.blank?
    end

    def url
      duns_token
      @api_url = "#{ENV.fetch('DNB_API_ENDPOINT', nil)}/v1/match/cleanseMatch?registrationNumber=#{@params[:id]}&countryISOAlpha2Code=GB"
    end

    def duns_token
      token_response = File.read('spec/stub_response/tokens/dnb_token.json')
      WebMock.stub_request(:post, "#{ENV.fetch('DNB_API_ENDPOINT', nil)}/v2/token")
             .with(
               body: '{"grant_type":"client_credentials"}',
               headers: stub_token_headers
             )
             .to_return(status: 200, body: token_response, headers: {})
    end

    def load_stub
      @result = File.read("spec/stub_response/api_duns_coh_stubs/#{@params[:scheme]}-#{@params[:id]}.json")
    rescue StandardError
      {}
    end
  end
end
