class ApplicationController < ActionController::API
    include ActionController::Cookies

  private

  def current_user
    @current_user ||= User.find_by(token: params[:token] || request.headers['X-User-Token'])
  end

  def require_user!
    render json: { error: 'Not logged in' }, status: :unauthorized unless current_user
  end
end
