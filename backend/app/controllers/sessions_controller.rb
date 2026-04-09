require 'net/http'
require 'json'

class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    if auth.nil?
      redirect_to "http://localhost:4321?error=auth_failed"
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

    redirect_to "http://localhost:4321/dash?uid=#{user.id}"
  end

  def me
    user = User.find_by(id: params[:uid])
    if user
      render json: {
        logged_in: true,
        name: user.name,
        email: user.email,
        slack_id: user.slack_id,
        verification_status: user.verification_status
      }
    else
      render json: { logged_in: false }, status: :unauthorized
    end
  end
end