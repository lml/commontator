module Commontator
  class ApplicationController < ActionController::Base
    protected
    def get_thread
      @thread = params[:thread_id].blank? ? \
        Commontator::Thread.find(params[:id]) : \
        Commontator::Thread.find(params[:thread_id])
      get_commontable_url
    end
    
    def get_commontable_url
      @commontable_url = @thread.config.commontable_url_proc.call(main_app, @thread.commontable)
    end
  end
end
