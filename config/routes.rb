Commontator::Engine.routes.draw do
  resources :threads, :only => [:show], :shallow => true do
    resources :comments, :except => [:index], :shallow => true
    put 'close', :on => :member
    put 'reopen', :on => :member
    get 'subscribe', :to => 'subscriptions#create',
                     :as => 'subscribe',
                     :on => :member
    get 'unsubscribe', :to => 'subscriptions#destroy',
                       :as => 'unsubscribe',
                       :on => :member
  end
  
  resources :subscriptions, :only => [:index]
end
