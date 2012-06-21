class CommentThread::CommentThreadSubscriptionsController < ApplicationController

  include CommentThread::CommentThreadsHelper

  before_filter :get_comment_thread, :except => :index

  # GET /subscriptions
  def index
    comment_threads = CommentThreadSubscription.find_all_by_user_id(present_user.id) \
                        .collect { |cts| cts.comment_thread }
    respond_with(@commentables = comment_threads.collect { |ct|
                                   ct.commentable.becomes(
                                     Kernel.const_get(ct.commentable_type)) })
  end

  # GET /1/comments/subscribe
  def create
    raise SecurityTransgression unless present_user.can_read?(@comment_thread)

    if !@comment_thread.subscribe!(present_user)
      flash[:alert] = "You cannot subscribe to this thread."
    end

    respond_to do |format|
      format.html { redirect_to(polymorphic_path([@commentable, :comments])) }
      format.js
    end

  end

  # GET /1/comments/unsubscribe
  def destroy
    raise SecurityTransgression unless present_user.can_read?(@comment_thread)

    if !@comment_thread.unsubscribe!(present_user)
      flash[:alert] = "You are not subscribed to this thread."
    end

    respond_to do |format|
      format.html do
        if @comment_thread.commentable_type == 'Message'
          redirect_to inbox_path
        else
          redirect_to(polymorphic_path([@commentable, :comments]))
        end
      end
      format.js
    end

  end

end
