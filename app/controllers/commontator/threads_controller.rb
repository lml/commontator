module Commontator
  class ThreadsController < ApplicationController
    before_filter :get_thread

    # GET /threads/1
    def show
      raise SecurityTransgression unless @thread.can_be_read_by?(@commontator)

      @thread.mark_as_read_for(@commontator)

      respond_to do |format|
        format.html { redirect_to commontable_url(@thread) }
        format.js
      end
    end
    
    # PUT /threads/1/close
    def close
      raise SecurityTransgression unless @thread.can_be_edited_by?(@commontator)

      @thread.close(@commontator)
      @thread.thread_closed_callback(@commontator)

      respond_to do |format|
        format.html { redirect_to commontable_url(@thread) }
      end
    end
    
    # PUT /threads/1/reopen
    def reopen
      raise SecurityTransgression unless @thread.can_be_edited_by?(@commontator)

      @thread.reopen

      respond_to do |format|
        format.html { redirect_to commontable_url(@thread) }
      end
    end
  end
end
