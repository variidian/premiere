OmniAuth.config.allowed_request_methods = [:get, :post]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2,
    ENV['HACKATIME_CLIENT_ID'],
    ENV['HACKATIME_CLIENT_SECRET'],
    name: :hackatime,
    provider_ignores_state: true,
    client_options: {
      site: 'https://hackatime.hackclub.com/',
      authorize_url: 'https://hackatime.hackclub.com/oauth/authorize',
      token_url: 'https://hackatime.hackclub.com/oauth/token',
    },
    scope: 'profile read'
end