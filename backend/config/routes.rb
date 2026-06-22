Rails.application.routes.draw do
  get "home/index"
  get '/auth/hackclub', as: :login
  get '/auth/hackclub/callback', to: 'sessions#create'
  get '/hackatime/connect', to: 'hackatime#connect'
  get '/auth/hackatime/callback', to: 'hackatime#create'
  get '/auth/failure', to: redirect('/')
  get '/auth/me', to: 'sessions#me'
  get '/hackatime/projects', to: 'hackatime#projects'
  post '/devlogs', to: 'devlogs#create'
  get '/devlogs', to: 'devlogs#index'
  get '/projects', to: 'projects#index'
  post '/projects', to: 'projects#create'
  get '/projects/accepted', to: 'projects#accepted'
  get '/projects/:id', to: 'projects#show'
  patch '/projects/:id', to: 'projects#update'
  post '/projects/:id/upload_image', to: 'projects#upload_image'
  post '/shop/purchase', to: 'shop#purchase'
  
  root "home#index"
end
