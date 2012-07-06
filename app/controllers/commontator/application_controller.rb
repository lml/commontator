module Commontator
  class ApplicationController < ActionController::Base
    before_filter :get_commontator
    
    protected
    
    def get_commontator
      @commontator = send Commontator.current_user_method
      raise SecurityTransgression unless (@commontator.nil? || @commontator.is_commontator)
    end
    
    def get_thread
      @thread = params[:thread_id].blank? ? \
        Commontator::Thread.find(params[:id]) : \
        Commontator::Thread.find(params[:thread_id])
    end
  end
end
