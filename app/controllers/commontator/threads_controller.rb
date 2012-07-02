module Commontator
  class ThreadsController < ApplicationController
  
    before_filter :get_thread

    # GET /threads/1
    def show
      raise SecurityTransgression unless @thread.can_be_read_by?(@user)

      @thread.mark_as_read_for(@user)

      respond_to do |format|
        format.html
        format.js
      end
    end
    
    protected

    def get_thread
      @thread = Thread.find(params[:id])
    end
    
  end
  
end
