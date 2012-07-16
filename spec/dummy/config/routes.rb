Rails.application.routes.draw do
  resources :dummy_models, :only => [:show] do
    get :hide, :on => :member
  end

  mount Commontator::Engine => "/commontator"
end
