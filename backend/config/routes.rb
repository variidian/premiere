Rails.application.routes.draw do
  get "home/index"
  get '/auth/hackclub', as: :login
  get '/auth/hackclub/callback', to: 'sessions#create'
  get '/hackatime/connect', to: 'hackatime#connect'
  get '/auth/hackatime/callback', to: 'hackatime#create'
  get '/auth/failure', to: redirect('/')
  get '/auth/me', to: 'sessions#me'
  get '/hackatime/projects', to: 'hackatime#projects'
  get '/admin/referrals', to: 'referrals#index'
  post '/admin/referrals/:id/approve', to: 'referrals#approve'
  get '/admin/projects', to: 'admin_projects#index'
  patch '/admin/projects/:id', to: 'admin_projects#update'
  post '/devlogs', to: 'devlogs#create'
  get '/devlogs', to: 'devlogs#index'
  get '/projects', to: 'projects#index'
  post '/projects', to: 'projects#create'
  patch '/projects/:id', to: 'projects#update'
  get '/projects/accepted', to: 'projects#accepted'
  post '/shop/purchase', to: 'shop#purchase'
  
  root "home#index"
end
