module Commontator
  class ApplicationController < ActionController::Base
  
    include ThreadsHelper
  
    before_filter :get_user
    
    protected
    
    def get_user
      @user = send Commontator.current_user_method_name
      raise SecurityTransgression unless @user.is_commontator
    end
    
  end
end
