module Commontator
  class CommentsController < ApplicationController
    helper ThreadsHelper

    before_filter :get_thread, :only => [:new, :create]
    before_filter :get_comment_and_thread, :except => [:new, :create]

    # GET /1/comments/new
    def new
      @comment = Comment.new
      @comment.thread = @thread
      @comment.commontator = @commontator

      raise SecurityTransgression unless @comment.can_be_created_by?(@commontator)

      respond_to do |format|
        format.html
        format.js
      end
     
    end

    # POST /1/comments
    def create
      @comment = Comment.new(params[:comment])
      @comment.thread = @thread
      @comment.commontator = @commontator
      
      raise SecurityTransgression unless @comment.can_be_created_by?(@commontator)

      respond_to do |format|
        if @comment.save
          @thread.subscribe(@commontator) if @thread.config.auto_subscribe_on_comment
          @thread.mark_as_unread_except_for(@commontator)
          SubscriptionsMailer.comment_created_email(@comment)
          @thread.comment_created_callback(@commontator, @comment)
          format.html { redirect_to @thread }
          format.js
        else
          @errors = @comment.errors
          format.html { render :action => 'new' }
          format.js
        end
      end
    end

    # GET /comments/1/edit
    def edit
      raise SecurityTransgression unless @comment.can_be_edited_by?(@commontator)

      respond_to do |format|
        format.html
        format.js
      end
    end

    # PUT /comments/1
    def update
      raise SecurityTransgression unless @comment.can_be_edited_by?(@commontator)

      respond_to do |format|
        if @comment.update_attributes(params[:comment])
          @thread.comment_edited_callback(@commontator, @comment)
          format.html { redirect_to @thread }
          format.js
        else
          format.html { render :action => "edit" }
          format.js
        end
      end
    end

    # PUT /comments/1/delete
    def delete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@commontator)

      @comment.delete(@commontator)
      @thread.comment_deleted_callback(@commontator, @comment)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/undelete
    def undelete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@commontator)

      @comment.undelete

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/upvote
    def upvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@commontator)
      
      @comment.upvote_from @commontator

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/downvote
    def downvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@commontator)
      
      @comment.downvote_from @commontator

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/unvote
    def unvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@commontator)
      
      @comment.unvote :voter => @commontator

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :vote }
      end
    end
    
    protected
    
    def get_comment_and_thread
      @comment = Comment.find(params[:id])
      @thread = @comment.thread
    end
  end
end
