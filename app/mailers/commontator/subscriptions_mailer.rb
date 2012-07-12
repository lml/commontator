module Commontator
  class SubscriptionsMailer < ActionMailer::Base
    include CommentsHelper
    include ThreadsHelper
  
    def comment_created_email(comment, commontable_url) 
      setup_variables(comment, commontable_url)

      mail(:bcc => @bcc, :subject => @subject) \
        unless @bcc.empty?
    end

protected

    def setup_variables(comment, commontable_url)
      
      @comment = comment
      @thread = @comment.thread
      @commontator = @comment.commontator
      
      @bcc = @thread.subscribers.reject{|s| s == @commontator}\
                                .collect{|s| email(s)}
      
      return if @bcc.empty?
      
      @commontable = @thread.commontable
      @config = @thread.config
      
      @commontator_name = commontator_name(@comment)
      @comment_timestamp = comment_timestamp(@comment)
      
      @commontable_name = commontable_name(@thread)
      @commontable_id = commontable_id(@thread).to_s
      
      @commontable_url = commontable_url
      
      params = Hash.new
      params[:comment] = @comment
      params[:thread] = @thread
      params[:commontator] = @commontator
      params[:commontable] = @commontable
      params[:config] = @config
      params[:commontator_name] = @commontator_name
      params[:comment_timestamp] = @comment_timestamp
      params[:commontable_name] = @commontable_name
      params[:commontable_id] = @commontable_id
      params[:commontable_url] = @commontable_url
      
      @subject = @config.subscription_email_subject_proc.call(params)
    end
  end
end
