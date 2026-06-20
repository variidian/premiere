OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.full_host = ENV.fetch('BACKEND_URL', 'http://localhost:3000')

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2,
    ENV['HACKATIME_CLIENT_ID'],
    ENV['HACKATIME_CLIENT_SECRET'],
    name: :hackatime,
    provider_ignores_state: true,
    setup: lambda { |env|
      request = Rack::Request.new(env)
      state = request.params['state']
      strategy = env['omniauth.strategy']
      strategy.options[:authorize_params][:state] = state if state.present?
      strategy.define_singleton_method(:callback_url) { full_host + callback_path }
    },
    client_options: {
      site: 'https://hackatime.hackclub.com/',
      authorize_url: 'https://hackatime.hackclub.com/oauth/authorize',
      token_url: 'https://hackatime.hackclub.com/oauth/token',
    },
    scope: 'profile read'
end
