module ActionDispatch::Routing
  class Mapper
    def commontable
      namespace :commontator do
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
      end
    end
    
    def commontator
      namespace :commontator do
        resources :subscriptions, :only => [:index], :shallow => true
      end
    end

    def commentable
      commontable
    end
    
    def commonter
      commontator
    end
    
    def commentator
      commontator
    end
    
    def commenter
      commontator
    end
  end
end
