module ActionDispatch::Routing
  class Mapper
    def commentable
      namespace :commontator do
        get 'comments', :to => 'threads#show',
                        :as => 'comments'
        resources :threads, :only => [], :shallow => true do
          resources :comments, :only => [:new, :create], :shallow => true
        end
        
        post 'subscribe', :to => 'subscriptions#create',
                          :as => 'subscribe'
        post 'unsubscribe', :to => 'subscriptions#destroy',
                            :as => 'unsubscribe'
      end
    end

    def commontable
      commentable
    end
  end
end
