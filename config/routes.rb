Commontator::Engine.routes.draw do
  resources :threads, :only => [:show] do
    resources :comments, :except => [:index, :destroy], :shallow => true do
      member do
        patch 'delete'
        patch 'undelete'
        
        patch 'upvote'
        patch 'downvote'
        patch 'unvote'
      end
    end
    
    member do
      patch 'close'
      patch 'reopen'
      
      patch 'subscribe', :to => 'subscriptions#subscribe'
      patch 'unsubscribe', :to => 'subscriptions#unsubscribe'
    end
  end
end
