require 'net/http'
require 'json'
require 'cgi'

class HackatimeController < ApplicationController
  before_action :require_user!, only: [:projects]

  def connect
    user = User.find_by(token: params[:token])
    return render json: { error: 'Not logged in' }, status: :unauthorized unless user

    session[:hackatime_link_token] = user.token
    redirect_to "/auth/hackatime?state=#{CGI.escape(signed_state(user))}"
  end

  def create
    user = user_from_state || User.find_by(token: session[:hackatime_link_token])
    return redirect_to frontend_projects_new('hackatime=failed&reason=missing_user'), allow_other_host: true unless user

    auth = request.env['omniauth.auth']
    return redirect_to frontend_projects_new('hackatime=failed&reason=missing_auth'), allow_other_host: true unless auth

    credentials = auth['credentials'] || {}

    user.update(
      hackatime_uid: auth.dig('uid') || auth.dig('info', 'id'),
      hackatime_access_token: credentials['token'],
      hackatime_refresh_token: credentials['refresh_token'],
      hackatime_expires_at: credentials['expires_at'] && Time.at(credentials['expires_at'])
    )

    session.delete(:hackatime_link_token)
    redirect_to frontend_projects_new('hackatime=connected'), allow_other_host: true
  end

  def projects
    return render json: { connected: false, projects: [] }, status: :unauthorized unless current_user.hackatime_access_token.present?

    responses = fetch_projects_responses
    return render json: { error: 'Could not reach Hackatime projects' }, status: :bad_gateway if responses.empty?

    successful_responses = responses.select { |res| res.is_a?(Net::HTTPSuccess) }
    return render json: { connected: false, projects: [] }, status: :unauthorized if successful_responses.empty? && responses.any? { |res| res.code.to_i == 401 }
    return render json: { error: 'Could not load Hackatime projects' }, status: :bad_gateway if successful_responses.empty?

    payloads = successful_responses.map { |res| JSON.parse(res.body) }
    projects = normalize_projects(payloads)
    render json: { connected: true, projects: projects }
  rescue JSON::ParserError
    render json: { error: 'Hackatime returned an unreadable response' }, status: :bad_gateway
  end

  private

  def signed_state(user)
    verifier.generate({ token: user.token, purpose: 'hackatime', created_at: Time.current.to_i })
  end

  def user_from_state
    state = verifier.verify(params[:state])
    purpose = state['purpose'] || state[:purpose]
    token = state['token'] || state[:token]
    return unless purpose == 'hackatime'

    User.find_by(token: token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, TypeError
    nil
  end

  def verifier
    Rails.application.message_verifier(:hackatime_oauth)
  end

  def fetch_projects_responses
    today = Date.current.iso8601
    paths = [
      '/api/v1/authenticated/projects?include_archived=true',
      '/api/v1/users/current/stats/all_time',
      "/api/v1/users/current/summaries?start=2000-01-01&end=#{today}",
      '/api/v1/users/current/projects',
      '/api/v1/users/me/projects',
      '/api/v1/projects'
    ]

    paths.filter_map do |path|
      uri = URI.join('https://hackatime.hackclub.com', path)
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Bearer #{current_user.hackatime_access_token}"
      req['Accept'] = 'application/json'

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      res if res.is_a?(Net::HTTPSuccess) || res.code.to_i == 401
    end
  end

  def normalize_projects(payloads)
    projects = {}

    Array(payloads).each do |payload|
      collect_projects(payload).each do |project|
        name = project[:name].to_s
        next if name.blank?

        projects[name] ||= { name: name, hours: nil }
        projects[name][:hours] = project[:hours] if project[:hours].present?
      end
    end

    projects.values.sort_by { |project| project[:name].downcase }
  end

  def collect_projects(value)
    case value
    when Array
      value.flat_map { |item| collect_projects(item) }
    when Hash
      explicit_projects = value['projects'] || value[:projects]
      explicit_data = value['data'] || value[:data]
      collected = []
      collected += collect_projects(explicit_data) if explicit_data.present?
      collected += collect_projects(explicit_projects) if explicit_projects.present?
      direct = project_from_hash(value)
      direct ? [direct] + collected : collected
    else
      []
    end
  end

  def project_from_hash(project)
    name = project['name'] || project[:name] || project['project'] || project[:project]
    return unless name.present?

    { name: name, hours: extract_hours(project) }
  end

  def extract_hours(project)
    seconds = project['total_seconds'] || project[:total_seconds] || project['seconds'] || project[:seconds]
    return (seconds.to_f / 3600).round(2) if seconds.present?

    minutes = project['total_minutes'] || project[:total_minutes] || project['minutes'] || project[:minutes]
    return (minutes.to_f / 60).round(2) if minutes.present?

    grand_total = project['grand_total'] || project[:grand_total]
    return extract_hours(grand_total) if grand_total.is_a?(Hash)

    hours = project['total_hours'] || project[:total_hours] || project['hours'] || project[:hours] || project['decimal'] || project[:decimal]
    hours&.to_f&.round(2)
  end

  def frontend_projects_new(query)
    "#{ENV['FRONTEND_URL'] || 'http://localhost:4321'}/projects/new?#{query}"
  end
end
