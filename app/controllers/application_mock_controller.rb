class ApplicationMockController < ActionController::API
  include Authorize::Token
  include WebMock::API
  rescue_from WebMock::NetConnectNotAllowedError, with: :return_error_code_http
  rescue_from ApiValidations::ApiError, with: :return_error_code
  before_action :validate_api_key

  def return_error_code_http
    render json: '', status: :not_found
  end

  def return_error_code(code)
    render json: '', status: code.to_s
  end
end
