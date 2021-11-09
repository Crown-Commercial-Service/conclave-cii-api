class ApplicationMockController < ActionController::API
  include Authorize::Token
  include WebMock::API
  rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
  rescue_from ApiValidations::ApiError, with: :return_error_code
  before_action :validate_api_key
  before_action :enable_mock_service
  attr_accessor :mock_service, :mock_controller

  def run_mock
    @mock_controller.request = request
    @mock_controller.response = response
    @mock_controller.validate_params if @mock_controller.respond_to?('validate_params')
  end

  def return_error_code_http
    disable_mock_service
    render json: '', status: :not_found
  end

  def return_error_code(code)
    disable_mock_service
    render json: '', status: code.to_s
  end

  def enable_mock_service
    @mock_service = MockingService::MockApis.new
  end

  def disable_mock_service
    @mock_service.disable_mock_service
  end

  def response_result(result)
    disable_mock_service
    if result.blank?
      render json: '', status: :not_found
    else
      render json: result
    end
  end

  def delete_response_result(result)
    disable_mock_service
    render json: result, status: :ok if result.blank?
  end

  def delete_additional_response_result(additional_org, primary_org_check)
    disable_mock_service
    if primary_org_check
      render json: '', status: :bad_request
    elsif additional_org.blank?
      render json: '', status: :not_found
    else
      render json: '', status: :ok
    end
  end
end
