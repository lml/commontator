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

      @commontable = @thread.commontable
      @config = @thread.config

      @creator_name = @creator.commontator_name

      @commontable_name = @commontable.commontable_name

      @commontable_url = ApplicationController.commontable_url

      params = Hash.new
      params[:comment] = @comment
      params[:thread] = @thread
      params[:creator] = @creator
      params[:commontable] = @commontable
      params[:config] = @config
      params[:creator_name] = @creator_name
      params[:commontable_name] = @commontable_name
      params[:commontable_url] = @commontable_url

      @to = t('commontator.email.undisclosed_recipients')
      @bcc = recipients.collect{|s| s.commontator_email(self)}
      @from = @config.email_from_proc.call(@thread)
    end
  end
end

