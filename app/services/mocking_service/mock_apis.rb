module MockingService
  class MockApis
    def initialize
      setup_stubs
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
      Dir.each_child('spec/stub_response') do |filename|
        MockingService::ApiStub.new(get_params(filename))
      end
    rescue StandardError
      {}
    end
  end
end
