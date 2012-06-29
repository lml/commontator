Commontator::Engine.routes.draw do
  
  resources :threads
  resources :comments
  resources :subscriptions
  
  #root :to => 'comments#index'
  
end
