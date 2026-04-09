class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    if auth.nil?
      redirect_to root_path, alert: "Authentication failed."
      return
    end


    user = User.find_or_create_by(uid: auth['uid']) do |u|
      u.name = auth['info']['name']
      u.email = auth['info']['email']
      u.profile = auth['info']['profile']
      u.verification_status = auth['info']['verification_status']
      u.slack_id = auth['info']['slack_id']
    end

    # Save user id in session
    session[:user_id] = user.id

    redirect_to "http://localhost:4321"
  end
end