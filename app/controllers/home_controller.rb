class HomeController < ActionController::API
  def index
    render json: ['No unauthorised access']
  end
end
