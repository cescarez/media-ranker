Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "homepages#index"

  resources :users, except: [:new, :update, :edit] do
    resources :votes, only: [:create, :index, :show]
  end

  get '/login', to: 'users#login', as: 'login_path'
  post '/login', to: 'users#login'
  post '/logout', to: 'users#logout', as: 'logout_path'

  resources :works do
    resources :votes, only: [:index, :show]
  end

end
