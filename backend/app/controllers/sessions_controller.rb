require 'net/http' #ruby libraries
require 'json'

class SessionsController < ApplicationController #controller inheriting from ApplicationController
  def create #defines action created in routes.rb
    auth = request.env['omniauth.auth'] #get OAuth payload from OmniAuth middleware

    if auth.nil?
      redirect_to "/?error=auth_failed"
      return
    end 

    #authenticated get request
    token = auth['credentials']['token']  
    uri = URI('https://auth.hackclub.com/api/v1/me')
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    #perform request, parse response
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    info = JSON.parse(res.body)

    #first time user creation (only runs if they don't exist already)
    user = User.find_or_create_by(uid: info['identity']['id']) do |u|
      u.name = "#{info['identity']['first_name']} #{info['identity']['last_name']}"
      u.email = info['identity']['primary_email']
      u.verification_status = info['identity']['verification_status']
      u.slack_id = info['identity']['slack_id']
      u.referred_by = session[:referral_code]
    end #end user creation

    session.delete(:referral_code) #clears session after saving referral code (if it was present)

      #api request to collect user pfp / slack display name using slack id
      cachet_uri = URI("https://cachet.dunkirk.sh/users/#{user.slack_id}")
      cachet_req = Net::HTTP::Get.new(cachet_uri)
      #perform request, parse response
      cachet_res = Net::HTTP.start(cachet_uri.hostname, cachet_uri.port, use_ssl: true) { |http| http.request(cachet_req) }
      cachet_info = JSON.parse(cachet_res.body)
      #updates db (ActiveRecord)
      user.update(
        avatar: cachet_info['imageUrl'],
        display_name: cachet_info['displayName']
      )
    #redirect to dashboard
    redirect_to "#{ENV['FRONTEND_URL'] || 'http://localhost:4321'}/dash?token=#{user.token}"
  end #closes def create

  def me #defines action set in routes.rb
    user = User.find_by(token: params[:token]) #finds user with their token set in user.rb
    if user #truthy check
      render json: { #rails api response
        #user fields
        logged_in: true,
        name: user.name,
        email: user.email,
        slack_id: user.slack_id,
        display_name: user.display_name,
        avatar: user.avatar,
        verification_status: user.verification_status,
        referred_by: user.referred_by,
        referral_paid: user.referral_paid
      }
    else
      render json: { logged_in: false }, status: :unauthorized 
    end 
  end #end def me
end #end controller