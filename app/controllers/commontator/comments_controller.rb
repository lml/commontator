module Commontator
  class CommentsController < Commontator::ApplicationController
    before_filter :get_thread, :only => [:new, :create]
    before_filter :get_comment_and_thread, :except => [:new, :create]
    before_filter :set_commontable_url, :only => :create

    # GET /threads/1/comments/new
    def new
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user

      raise SecurityTransgression unless @comment.can_be_created_by?(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
     
    end

    # POST /threads/1/comments
    def create
      @comment = Comment.new
      @comment.body = params[:comment].nil? ? nil : params[:comment][:body]
      @comment.thread = @thread
      @comment.creator = @user
      
      raise SecurityTransgression unless @comment.can_be_created_by?(@user)
      
      respond_to do |format|
        if @comment.save
          @thread.subscribe(@user) if @thread.config.auto_subscribe_on_comment
          @thread.add_unread_except_for(@user)
          recipients = @thread.active_subscribers.reject{|s| s == @user}
          SubscriptionsMailer.comment_created(@comment, recipients).deliver \
            unless recipients.empty?

          format.html { redirect_to @thread }
          format.js
        else
          format.html { redirect_to @thread }
          format.js { render :new }
        end
      end
    end

    # GET /comments/1/edit
    def edit
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end
    end

    # PUT /comments/1
    def update
      raise SecurityTransgression unless @comment.can_be_edited_by?(@user)
      @comment.body = params[:comment].nil? ? nil : params[:comment][:body]
      @comment.editor = @user

      respond_to do |format|
        if @comment.save
          format.html { redirect_to @thread }
          format.js
        else
          format.html { redirect_to @thread }
          format.js { render :edit }
        end
      end
    end

    # PUT /comments/1/delete
    def delete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.errors.add(:base, 'This comment has already been deleted.') \
        unless @comment.delete_by(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/undelete
    def undelete
      raise SecurityTransgression unless @comment.can_be_deleted_by?(@user)

      @comment.errors.add(:base, 'This comment is not deleted.') \
        unless @comment.undelete_by(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :delete }
      end
    end
    
    # PUT /comments/1/upvote
    def upvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.upvote_from @user

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/downvote
    def downvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.downvote_from @user

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :vote }
      end
    end
    
    # PUT /comments/1/unvote
    def unvote
      raise SecurityTransgression unless @comment.can_be_voted_on_by?(@user)
      
      @comment.unvote :voter => @user

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
