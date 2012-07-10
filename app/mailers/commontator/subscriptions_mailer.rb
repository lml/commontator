module Commontator
  class SubscriptionsMailer < ActionMailer::Base
  
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
      params = Hash.new
      params[:comment] = comment
      params[:thread] = params[:comment].thread
      params[:commontator] = params[:comment].commontator
      params[:commontable] = params[:thread].commontable
      params[:config] = params[:thread].config
      @bcc = params[:thread].subscribers.reject{|s| s == params[:commontator]}\
                                        .collect{|s| email(s)}
                                
      params[:commontator_name] = commontator_name(params[:comment])
      params[:comment_timestamp] = comment_timestamp(params[:comment])
      
      params[:commontable_name] = commontable_name(params[:thread])
      params[:commontable_id] = commontable_id(params[:thread]).to_s
      
      @subject = params[:config].subscription_email_subject_proc.call(params)
      @body = params[:config].subscription_email_body_proc.blank? ? nil : \
                params[:config].subscription_email_body_proc.call?(params)
    end

  end
end
