class ApplicationController < ActionController::API
    include ActionController::Cookies #enables sessions (disabled by default on api mode)

    before_action :store_referral #runs on every request

  private #only for use internally by the controller

  def store_referral
    session[:referral_code] = params[:r] if params[:r].present? #saves code to session if /?r=(code) is present
  end
end
