module Commontator
  class SubscriptionsMailer < ActionMailer::Base
    include SharedHelper
    include ThreadsHelper
  
    def comment_created(comment, recipients)
      setup_variables(comment, recipients)

      mail :to => @to,
           :bcc => @bcc,
           :from => @from,
           :subject => @subject
    end

    protected

    def setup_variables(comment, recipients)
      @comment = comment
      @thread = @comment.thread
      @creator = @comment.creator

      @commontable = @thread.commontable
      @config = @thread.config

      @creator_name = commontator_name(@creator)
      @comment_created_timestamp = @comment.created_timestamp

      @commontable_name = commontable_name(@thread)

      @commontable_url = ApplicationController.commontable_url

      params = Hash.new
      params[:comment] = @comment
      params[:thread] = @thread
      params[:creator] = @creator
      params[:commontable] = @commontable
      params[:config] = @config
      params[:creator_name] = @creator_name
      params[:comment_created_timestamp] = @comment_created_timestamp
      params[:commontable_name] = @commontable_name
      params[:commontable_url] = @commontable_url

      @to = @config.subscription_email_to_proc.call(params)
      @bcc = recipients.collect{|s| commontator_email(s)}
      @from = @config.subscription_email_from_proc.call(params)
      @subject = @config.subscription_email_subject_proc.call(params)
    end
  end
end
