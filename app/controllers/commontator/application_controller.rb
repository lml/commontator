module Commontator
  class ApplicationController < ActionController::Base
  
    before_filter :get_user
    
    protected
    
    def get_user
      @user = send Commontator.current_user_method
      raise SecurityTransgression unless @user.is_commontator
    end
    
  end
end
