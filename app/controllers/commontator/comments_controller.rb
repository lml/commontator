module Commontator
  class CommentsController < ApplicationController
    before_filter :get_thread, :only => [:new, :create]
    before_filter :get_comment_and_thread, :except => [:new, :create]

    # GET /1/comments/new
    def new
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user

      raise SecurityTransgression unless @comment.can_be_created_by?(@user)

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js
      end
     
    end

    # POST /1/comments
    def create
      @comment = Comment.new(params[:comment])
      @comment.thread = @thread
      @comment.creator = @user
      
      raise SecurityTransgression unless @comment.can_be_created_by?(@user)
      
      if @comment.save
        @thread.subscribe(@user) if @thread.config.auto_subscribe_on_comment
        @thread.mark_as_unread_except_for(@user)
        SubscriptionsMailer.comment_created_email(@comment, @commontable_url)
        @thread.comment_created_callback(@user, @comment)
      else
        @errors = @comment.errors
      end

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js
      end
    end

    # GET /comments/1/edit
    def edit
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js
      end
    end

    # PUT /comments/1
    def update
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)
      
      @thread.comment_edited_callback(@user, @comment) \
        if @comment.update_attributes(params[:comment])

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js
      end
    end

    # PUT /comments/1/delete
    def delete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.delete(@user)
      @thread.comment_deleted_callback(@user, @comment)

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/undelete
    def undelete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.undelete

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/upvote
    def upvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.upvote_from @user

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/downvote
    def downvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.downvote_from @user

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/unvote
    def unvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.unvote :voter => @user

      respond_to do |format|
        format.html { redirect_to @commontable_url, :show => true }
        format.js { render :vote }
      end
    end
    
    protected
    
    def get_comment_and_thread
      @comment = Comment.find(params[:id])
      @thread = @comment.thread
      get_commontable_url
    end
  end
end
