Rails.application.routes.draw do
  resources :items do
    resources :orders, shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
