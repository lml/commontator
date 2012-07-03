module Commontator
  class CommentsController < ApplicationController

    before_filter :get_thread, :only => [:new, :create]
    before_filter :get_comment_and_thread, :except => [:new, :create]

    # GET /1/comments/new
    def new
      @comment = Comment.new
      @comment.thread = @thread
      @comment.commenter = @user

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
          @thread.comment_posted_callback(@user, @comment)
          flash[:notice] = @thread.comment_name + ' ' + @thread.comment_verb
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
          flash[:notice] = @thread.comment_name + ' updated'
          @thread.comment_edited_callback(@user, @comment)
          format.html { redirect_to @thread }
          format.js
        else
          format.html { render :action => "edit" }
          format.js
        end
      end
    end

    # DELETE /comments/1
    def destroy
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.destroy
      @thread.comment_deleted_callback(@user, @comment)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end

  end
end
