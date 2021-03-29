class ApplicationMockController < ActionController::API
  include Authorize::Token
  include WebMock::API
end
