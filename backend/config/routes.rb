Rails.application.routes.draw do
  # All routes must be inside this block
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  
  # ... other routes
end