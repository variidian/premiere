class SessionsController < ApplicationController
    def create
      auth = request.env['omniauth.auth']
      #find or create user
      user = User.find_or_create_by(uid: auth['uid']) do |u|
        u.openid = auth['info']['openid']
        u.name = auth['info']['name']
        u.email = auth['info']['email']
        u.profile = auth['info']['profile']
        u.verification_status = auth['info']['verification_status']
        u.slack_id = auth['info']['slack_id']
      end
      session[:user_id] = user.id
      redirect_to root_path
    end
  end