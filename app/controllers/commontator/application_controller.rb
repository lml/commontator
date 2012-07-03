module Commontator
  class ApplicationController < ActionController::Base
  
    include ThreadsHelper
  
    before_filter :get_user
    
    protected
    
    def get_user
      @user = send Commontator.current_user_method
      raise SecurityTransgression unless @user.respond_to?(:is_thread_admin)
    end
    
  end
end
