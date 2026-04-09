Rails.application.routes.draw do
  get "home/index"
  get '/auth/hackclub', as: :login
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  get '/auth/me', to: 'sessions#me'
  
  root "home#index"
end