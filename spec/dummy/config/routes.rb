Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root controller: :dummy_models, action: :show, id: 1

  resources :dummy_models, only: :show

  mount Commontator::Engine => :commontator
end
