module Commontator
  class ThreadsController < ApplicationController
    before_filter :get_thread

    # GET /threads/1
    def show
      commontator_thread_show(@thread.commontable, @user)

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js
      end
    end
    
    # PUT /threads/1/close
    def close
      raise SecurityTransgression unless @thread.can_be_edited_by?(@user)

      @thread.close(@user)
      @thread.thread_closed_callback(@user)

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
      end
    end
    
    # PUT /threads/1/reopen
    def reopen
      raise SecurityTransgression unless @thread.can_be_edited_by?(@user)

      @thread.reopen

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
      end
    end
  end
end
