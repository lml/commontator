module Commontator
  class SubscriptionMailer < ActionMailer::Base
  
    include CommentsHelper
    include ThreadsHelper
  
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
                                .collect{|s| email(s)}
                                
      @commontator_name = commontator_name(@comment)
      @comment_timestamp = comment_timestamp(@comment)
      
      @commontable_name = commontable_name(@thread)
      @commontable_id = commontable_id(@thread).to_s
      
      @subject = eval(@config.subscription_email_subject)
      @body = @config.subscription_email_body.blank? ? nil : \
                eval(@config.subscription_email_body)
    end

  end
end
