class ApplicationMockController < ActionController::API
  include Authorize::Token
  include WebMock::API
  rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
  rescue_from ApiValidations::ApiError, with: :return_error_code
  before_action :validate_api_key
  before_action :enable_mock_service
  after_action :disable_mock_service
  attr_accessor :mock_service, :mock_controller
  
  def run_mock
    @mock_controller.request = request
    @mock_controller.response = response
  end
 
  def return_error_code_http
    render json: '', status: :not_found
  end

  def return_error_code(code)
    render json: '', status: code.to_s
  end

  def enable_mock_service
    @mock_service = MockingService::MockApis.new
  end

  def disable_mock_service
    @mock_service.disable_mock_service
  end

  def response_result(result)
    if result.blank?
      render json: '', status: :not_found
    else
      render json: result
    end
  end
end
