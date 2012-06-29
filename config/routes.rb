Commontator::Engine.routes.draw do
  def commontable
    resources :comments, :only => [:index, :new, :create]
    post 'subscribe', :to => 'subscriptions#create',
                      :as => 'subscribe'
    post 'unsubscribe', :to => 'subscriptions#destroy',
                        :as => 'unsubscribe'
  end
  
  def commentable
    commontable
  end
  
  resources :threads
  resources :comments
  resources :subscriptions
  
  #root :to => 'comments#index'
  
end
