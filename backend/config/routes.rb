Rails.application.routes.draw do
  get "home/index"
  get '/auth/hackclub', as: :login
  get '/auth/hackclub/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  get '/auth/me', to: 'sessions#me'
  post '/devlogs', to: 'devlogs#create'
  get '/devlogs', to: 'devlogs#index'
  
  root "home#index"
end