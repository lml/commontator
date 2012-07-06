module Commontator
  class SubscriptionMailer < ActionMailer::Base
  
    def comment_created_email(comment) 
      setup_variables(comment)

      mail(:bcc => @bcc,
           :subject => @subject,
           :body => @body)
    end

protected

    def setup_variables(comment)
      @comment = comment
      @thread = @comment.thread
      @commontator = @comment.commontator
      @commontable = @thread.commontable
      @config = @thread.config
      @bcc = @thread.subscribers.reject{|s| s == @commontator}\
                                .collect{|s| s.send @config.commontator_email_method}
      @subject = eval(@config.subscription_email_subject)
      @body = @config.subscription_email_body.nil? ? nil : \
                eval(@config.subscription_email_body)
    end

  end
end
