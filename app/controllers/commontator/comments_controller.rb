module Commontator
  class CommentsController < ApplicationController
    
    include ThreadsHelper

    before_filter :get_thread, :only => [:new, :create]
    before_filter :get_comment_and_thread, :except => [:new, :create]

    # GET /1/comments/new
    def new
      @comment = Comment.new
      @comment.thread = @thread
      @comment.commontator = @user

      raise SecurityTransgression unless @comment.can_be_created_by?(@user)

      respond_to do |format|
        format.html
        format.js
      end
     
    end

    # POST /1/comments
    def create
      @comment = Comment.new(params[:comment])
      @comment.thread = @thread
      @comment.creator = @user
      
      raise SecurityTransgression unless @comment.can_be_created_by?(@user)

      respond_to do |format|
        if @comment.save
          @thread.comment_created_callback(@user, @comment)
          flash[:notice] = @thread.config.comment_name + ' ' + @thread.config.comment_create_verb_past
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
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)

      respond_to do |format|
        format.html
        format.js
      end
    end

    # PUT /comments/1
    def update
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)

      respond_to do |format|
        if @comment.update_attributes(params[:comment])
          flash[:notice] = @thread.config.comment_name + ' ' + @thread.config.comment_edit_verb_past
          @thread.comment_edited_callback(@user, @comment)
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
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.delete(@user)
      @thread.comment_deleted_callback(@user, @comment)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end
    
    # PUT /comments/1/undelete
    def undelete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.undelete

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end

  end
end
