module Commontator
  class ApplicationController < ActionController::Base
  
    before_filter :get_commontator
    
    protected
    
    def get_user
      @commontator = send Commontator.current_user_method
      raise SecurityTransgression unless (@commontator.nil? || @commontator.is_commontator)
    end
    
  end
end
