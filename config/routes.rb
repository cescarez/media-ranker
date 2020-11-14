Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "homepages#index"


  get '/users/current', to: 'users#current', as: 'current_user'

  get '/login', to: 'users#login_form', as: 'login'
  post '/login', to: 'users#login'
  post '/logout', to: 'users#logout', as: 'logout'

  resources :users, only: [:create, :index, :show]

  post '/works/:id/upvote', to: 'works#upvote', as: "upvote_work"

  resources :works

end
