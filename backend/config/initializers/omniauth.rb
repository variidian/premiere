OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.full_host = ENV.fetch('BACKEND_URL', 'http://localhost:3000')

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2,
    ENV['CLIENT_ID'],
    ENV['CLIENT_SECRET'],
    name: :hackclub,
    provider_ignores_state: true,
    setup: lambda { |env|
      env['omniauth.strategy'].define_singleton_method(:callback_url) { full_host + callback_path }
    },
    client_options: {
      site: 'https://auth.hackclub.com',
      authorize_url: 'https://auth.hackclub.com/oauth/authorize',
      token_url: 'https://auth.hackclub.com/oauth/token',
    },
    scope: 'openid email name profile verification_status slack_id'
end
