Rails.application.routes.draw do
  get "home/index"
  # Login with Hack Club
  get '/auth/hackclub', as: :login

  # Callback after login
  get '/auth/:provider/callback', to: 'sessions#create'

  # Failure
  get '/auth/failure', to: redirect('/')

  # Your other routes
  root "home#index"
end