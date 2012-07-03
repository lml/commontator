module Commontator
  class SubscriptionMailer < ActionMailer::Base
  
    def comment_created_email(comment) 
      setup_variables(comment)

      mail(:bcc => @subscribers.reject{ |s| s == @commenter }.collect { |s| s.email },
           :subject => @commentable.subscription_email_subject,
           :body => @commentable.subscription_email_body
    end

protected

    def setup_variables(comment)
      @commenter = comment.commenter
      @commentable = comment.thread.commentable
      @subscribers = @thread.subscribers
    end

  end
end
