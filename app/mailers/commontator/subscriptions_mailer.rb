module Commontator
  class SubscriptionsMailer < ActionMailer::Base
    def comment_created(comment, recipients)
      setup_variables(comment, recipients)
      message = mail :to => @to,
                     :bcc => @bcc,
                     :from => @from,
                     :subject => t('commontator.email.comment_created.subject',
                                   :creator_name => @creator_name,
                                   :commontable_name => @commontable_name,
                                   :comment_url => @comment_url)

      message.mailgun_recipient_variables = mailgun_recipient_variables(recipients) if uses_mailgun?
    end

    protected

    def setup_variables(comment, recipients)
      @comment = comment
      @thread = @comment.thread
      @creator = @comment.creator

      @creator_name = Commontator.commontator_name(@creator)

      @commontable_name = Commontator.commontable_name(@thread)

      @comment_url = Commontator.comment_url(@comment, main_app)

      params = Hash.new
      params[:comment] = @comment
      params[:thread] = @thread
      params[:creator] = @creator
      params[:creator_name] = @creator_name
      params[:commontable_name] = @commontable_name
      params[:comment_url] = @comment_url

      if uses_mailgun?
        @to = recipient_emails(recipients)
      else
        @to = t('commontator.email.undisclosed_recipients')
        @bcc = recipient_emails(recipients)
      end

      @from = @thread.config.email_from_proc.call(@thread)
    end

    def recipient_emails(recipients)
      recipients.collect{ |s| Commontator.commontator_email(s, self) }
    end

    def mailgun_recipient_variables(recipients)
      recipient_emails(recipients).each_with_object({}) do |user_email, memo|
        memo[user_email] = {}
      end
    end

    def uses_mailgun?
      Rails.application.config.action_mailer.delivery_method == :mailgun
    end
  end
end
