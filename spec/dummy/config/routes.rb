Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'dummy_models#show', id: 1

  resources :dummy_models, only: :show do
    get :hide, on: :member
  end

  mount Commontator::Engine => '/commontator'
end
