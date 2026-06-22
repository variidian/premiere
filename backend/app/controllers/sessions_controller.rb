require 'net/http' 
require 'json'

class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    if auth.nil?
      redirect_to "/?error=auth_failed"
      return
    end 

    token = auth['credentials']['token']  
    uri = URI('https://auth.hackclub.com/api/v1/me')
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    info = JSON.parse(res.body)

    user = User.find_or_create_by(uid: info['identity']['id']) do |u|
      u.name = "#{info['identity']['first_name']} #{info['identity']['last_name']}"
      u.email = info['identity']['primary_email']
      u.verification_status = info['identity']['verification_status']
      u.slack_id = info['identity']['slack_id']
    end

      cachet_uri = URI("https://cachet.dunkirk.sh/users/#{user.slack_id}")
      cachet_req = Net::HTTP::Get.new(cachet_uri)
      cachet_res = Net::HTTP.start(cachet_uri.hostname, cachet_uri.port, use_ssl: true) { |http| http.request(cachet_req) }
      cachet_info = JSON.parse(cachet_res.body)
      user.update(
        avatar: cachet_info['imageUrl'],
        display_name: cachet_info['displayName']
      )
    redirect_to "#{ENV['FRONTEND_URL'] || 'http://localhost:4321'}/dash?token=#{user.token}", allow_other_host: true
  end

  def me
    user = User.find_by(token: params[:token])
    if user 
      render json: {
        logged_in: true,
        name: user.name,
        email: user.email,
        slack_id: user.slack_id,
        display_name: user.display_name,
        avatar: user.avatar,
        verification_status: user.verification_status,
        clapperboards: user.clapperboards,
        hackatime_connected: user.hackatime_access_token.present?,
        admin: user.admin?
      }
    else
      render json: { logged_in: false }, status: :unauthorized 
    end 
  end
end
