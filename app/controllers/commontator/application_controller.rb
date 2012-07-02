module Commontator
  class ApplicationController < ActionController::Base
  
    before_filter :get_user
    
    protected
    
    def get_user
      @user = current_user
    end
    
  end
end
