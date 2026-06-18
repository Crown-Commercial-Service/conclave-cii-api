class ApplicationController < ActionController::API
  def route_not_found
    render json: { message: 'Not Found' }, status: :not_found
  end
end
