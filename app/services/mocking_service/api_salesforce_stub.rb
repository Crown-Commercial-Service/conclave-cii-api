module MockingService
  class ApiSalesforceStub
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
      saleforce_token
      salesforce = Salesforce::Search.new(@params[:id], @params[:scheme])
      url_argument = salesforce.build_arguments
      @api_url = "#{ENV['SALESFORCE_AUTH_URL']}/services/data/v45.0/query?q=SELECT+ID,name,Status__c,Supplier_DUNS_Number__c,Company_Registration_Number__c,Account_URN__c+FROM+account+WHERE+#{url_argument}"
    end

    def saleforce_token
      token_response = File.read('spec/stub_response/tokens/salesforce_token.json')
      salesforce = Salesforce::Search.new(@params[:id], @params[:scheme])
      salesforce.post_params.inspect
      WebMock.stub_request(:post, "#{ENV['SALESFORCE_AUTH_URL']}/services/oauth2/token")
             .with(
               body: salesforce.post_params,
               headers: stub_token_headers
             )
             .to_return(status: 200, body: token_response, headers: {})
    end

    def load_stub
      @result = File.read("spec/stub_response/salesforce/#{@params[:scheme]}-#{@params[:id]}.json")
    rescue StandardError
      {}
    end
  end
end
