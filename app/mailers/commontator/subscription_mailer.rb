module Commontator
  class SubscriptionMailer < ActionMailer::Base
  
    def comment_created_email(comment) 
      setup_variables(comment)

      mail(:bcc => @subscribers.reject{ |s| s == @commontator }.collect { |s| s.email },
           :subject => @commontable.subscription_email_subject,
           :body => @commontable.subscription_email_body
    end

protected

    def setup_variables(comment)
      @commontator = comment.commontator
      @commontable = comment.thread.commontable
      @subscribers = @thread.subscribers
    end

  end
end
