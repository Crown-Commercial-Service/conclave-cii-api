module MockingService
  class MockApis
    include WebMock::API
    def initialize
      enable_mock_service
      setup_stubs
    end

    def enable_mock_service
      WebMock.enable!
      WebMock.disable_net_connect!(allow_localhost: false)
    end

    def get_params(filename)
      params = {}
      params[:scheme] = scheme(filename)
      params[:id] = scheme_id(filename)
      params
    end

    def scheme(filename)
      split_file_path = filename.split('-')
      "#{split_file_path[0]}-#{split_file_path[1]}"
    end

    def scheme_id(filename)
      split_file_path = filename.split('-')
      split_id = split_file_path[2].split('.')
      split_id[0]
    end

    def setup_stubs
      setup_api_stubs
      setup_salesforce_stubs
      setup_salesforce_api
      setup_duns_coh_api
      setup_spotlight_stubs
    end

    def setup_api_stubs
      Dir.each_child('spec/stub_response/api_stubs') do |filename|
        MockingService::ApiStub.new(get_params(filename))
      rescue StandardError
        {}
      end
    rescue StandardError
      {}
    end

    def setup_salesforce_stubs
      Dir.each_child('spec/stub_response/salesforce') do |filename|
        MockingService::ApiSalesforceStub.new(get_params(filename))
      rescue StandardError
        {}
      end
    rescue StandardError
      {}
    end

    def setup_spotlight_stubs
      Dir.each_child('spec/stub_response/spotlight') do |filename|
        MockingService::ApiSpotlightStub.new(get_params(filename))
      rescue StandardError
        {}
      end
    rescue StandardError
      {}
    end

    def setup_salesforce_api
      Dir.each_child('spec/stub_response/api_salesforce') do |filename|
        MockingService::MigrationSalesforceApi.new(get_params(filename))
      rescue StandardError
        {}
      end
    rescue StandardError
      {}
    end

    def setup_duns_coh_api
      Dir.each_child('spec/stub_response/api_duns_coh_stubs') do |filename|
        MockingService::ApiDunsCohStub.new(get_params(filename))
      rescue StandardError
        {}
      end
    rescue StandardError
      {}
    end

    def disable_mock_service
      WebMock.disable!
    end
  end
end
