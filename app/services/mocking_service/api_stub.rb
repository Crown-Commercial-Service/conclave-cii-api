module MockingService
  class ApiStub
    include WebMock::API

    def initialize(params)
      @params = params
      @params[:id] = Common::ApiHelper.clean_charity_number(@params[:id], @params[:scheme])
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
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v1.3.0'
      }
    end

    def http_status
      '404' unless @result.nil?
      '200' if @result.blank?
    end

    def url
      case @params[:scheme]
      when Common::AdditionalIdentifier::SCHEME_COMPANIES_HOUSE
        @api_url = "#{ENV['COMPANIES_HOUSE_API_ENDPOINT']}/company/#{@params[:id]}"
      when Common::AdditionalIdentifier::SCHEME_ENG_WALES_CHARITY, Common::AdditionalIdentifier::SCHEME_NORTHEN_IRELAND_CHARITY, Common::AdditionalIdentifier::SCHEME_SCOTISH_CHARITY
        @api_url = "#{ENV['FINDTHATCHARITY_API_ENDPOINT']}/orgid/#{@params[:scheme]}-#{@params[:id]}.json"
      when Common::AdditionalIdentifier::SCHEME_DANDB
        duns_token
        @api_url = "#{ENV['DNB_API_ENDPOINT']}/v1/data/duns/#{@params[:id]}?productId=cmptcs&versionId=v1"
      when Common::AdditionalIdentifier::SCHEME_NHS
        @api_url = "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations/#{@params[:id]}"
      end
    end

    def duns_token
      token_response = File.read('spec/stub_response/tokens/dnb_token.json')
      WebMock.stub_request(:post, "#{ENV['DNB_API_ENDPOINT']}/v2/token")
             .with(
               body: '{"grant_type":"client_credentials"}',
               headers: stub_headers
             )
             .to_return(status: 200, body: token_response, headers: {})
    end

    def load_stub
      @result = File.read("spec/stub_response/api_stubs/#{@params[:scheme]}-#{@params[:id]}.json")
    rescue StandardError
      {}
    end
  end
end
