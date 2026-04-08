OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :hackclub,
      ENV['CLIENT_ID'],
      ENV['CLIENT_SECRET'],
      client_options: {
        site: 'https://auth.hackclub.com',
        authorize_url: 'https://auth.hackclub.com/oauth/authorize',
        token_url: 'https://auth.hackclub.com/oauth/token'
      },
      scope: 'openid email name profile verification_status slack_id'
  end