module Commontator
  class SubscriptionsMailer < ActionMailer::Base
    def comment_created(comment, recipients)
      setup_variables(comment, recipients)

      mail :to => @to,
           :bcc => @bcc,
           :from => @from,
           :subject => t('commontator.email.comment_created.subject',
                         :creator_name => @creator_name,
                         :commontable_name => @commontable_name,
                         :commontable_url => @commontable_url)
    end

    protected

    def setup_variables(comment, recipients)
      @comment = comment
      @thread = @comment.thread
      @creator = @comment.creator

      @creator_name = Commontator.commontator_name(@creator)

      @commontable_name = Commontator.commontable_name(@thread)

      @commontable_url = Commontator.commontable_url(@thread)

      params = Hash.new
      params[:comment] = @comment
      params[:thread] = @thread
      params[:creator] = @creator
      params[:creator_name] = @creator_name
      params[:commontable_name] = @commontable_name
      params[:commontable_url] = @commontable_url

      @to = t('commontator.email.undisclosed_recipients')
      @bcc = recipients.collect{|s| Commontator.commontator_email(s, self)}
      @from = @thread.config.email_from_proc.call(@thread)
    end

    
  end
end

