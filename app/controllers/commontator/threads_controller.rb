module Commontator
  class ThreadsController < Commontator::ApplicationController
    skip_before_filter :ensure_user, :only => :show
    before_filter :set_thread

    # GET /threads/1
    def show
      commontator_thread_show(@thread.commontable)
      @show_all = params[:show_all] && @thread.can_be_edited_by?(@user)

      respond_to do |format|
        format.html { redirect_to main_app.polymorphic_path(@thread.commontable) }
        format.js
      end
    end

    # GET /threads/1/hide
    def hide
      respond_to do |format|
        format.js
      end
    end
    
    # PUT /threads/1/close
    def close
      security_transgression_unless @thread.can_be_edited_by?(@user)

      @thread.errors.add(:base, t('commontator.thread.errors.already_closed')) \
        unless @thread.close(@user)

      @show_all = true

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :show }
      end
    end
    
    # PUT /threads/1/reopen
    def reopen
      security_transgression_unless @thread.can_be_edited_by?(@user)

      @thread.errors.add(:base, t('commontator.thread.errors.not_closed')) \
        unless @thread.reopen

      @show_all = true

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :show }
      end
    end
  end
end
