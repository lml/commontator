module Commontator
  class ApplicationController < ActionController::Base
    before_filter :get_user
    
    cattr_accessor :commontable_url
    
    rescue_from SecurityTransgression, :with => lambda { head(:forbidden) }
    
    protected
    
    def get_user
      @user = self.send Commontator.current_user_method	
      raise SecurityTransgression unless (@user.nil? || @user.is_commontator)
    end
    
    def get_thread
      @thread = params[:thread_id].blank? ? \
        Commontator::Thread.find(params[:id]) : \
        Commontator::Thread.find(params[:thread_id])
      raise SecurityTransgression if @thread.commontable.nil?
    end
    
    def set_commontable_url
      self.commontable_url = @thread.config.commontable_url_proc.call(main_app, @thread.commontable)
    end
  end
end
