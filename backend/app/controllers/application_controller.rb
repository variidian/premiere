class ApplicationController < ActionController::API
    include ActionController::Cookies #enables sessions (disabled by default on api mode)

    before_action :store_referral #runs on every request

  private #only for use internally by the controller

  def current_user
    @current_user ||= User.find_by(token: params[:token] || request.headers['X-User-Token'])
  end

  def require_user!
    render json: { error: 'Not logged in' }, status: :unauthorized unless current_user
  end

  def store_referral
    session[:referral_code] = params[:r] if params[:r].present? #saves code to session if /?r=(code) is present
  end
end
