require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.session_store :cookie_store, key: '_premiere_session', same_site: :lax, secure: false
   
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
      key: '_premiere_session',
      same_site: :lax,
      secure: false
    config.middleware.use ActionDispatch::Flash

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:4321', 'https://premiere-ysws.vercel.app'
        resource '*',
          headers: :any,
          methods: [:get, :post, :options],
          credentials: true
      end
    end

    require 'dotenv/load' if Rails.env.development? || Rails.env.test?
  end
end
