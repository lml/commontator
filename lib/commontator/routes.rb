module ActionDispatch::Routing
  class Mapper
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
  end
end
