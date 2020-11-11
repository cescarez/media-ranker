Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "homepages#index"

  resources :users do
    resources :votes, only: [:create, :index, :show]
  end
  resources :works do
    resources :votes, only: [:index, :show]
  end
end
