class SubscriptionMailer < ActionMailer::Base

  helper :application
  
  def comment_created_email(comment) 
    setup_variables(comment)

    mail(:bcc => @subscribers.reject{ |s| s == @creator }.collect { |s| s.comment_thread_email },
         :subject => @commentable.comment_thread_subscription_subject
  end

private

  def setup_variables(comment)
    @comment = comment
    @creator = comment.creator
    @thread = comment.thread
    @commentable = @thread.commentable.becomes(
      @comment_thread.commentable_type.constantize)
    @subscribers = @thread.subscribers
    @type = @thread.commentable_type
  end

end
