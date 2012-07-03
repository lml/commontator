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
    
    # PUT /threads/1/close
    def close
      raise SecurityTransgression unless @thread.can_be_edited_by?(@user)

      @thread.close(@user)
      @thread.thread_closed_callback(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end
    
    # PUT /threads/1/reopen
    def reopen
      raise SecurityTransgression unless @thread.can_be_edited_by?(@user)

      @thread.reopen

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end
    
  end
  
end
