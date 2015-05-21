require 'rails_helper'
require 'mailgun_rails'

module Commontator
  RSpec.describe SubscriptionsMailer, type: :mailer do
    before(:each) do
      setup_mailer_spec
      @user2 = DummyUser.create
      @thread.subscribe(@user)
      @thread.subscribe(@user2)
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
      @comment.save!
      @recipients = @thread.subscribers.reject{|s| s == @user}
    end

    it 'must create deliverable mail' do
      mail = described_class.comment_created(@comment, @recipients)
      expect(mail.to).to eq I18n.t('commontator.email.undisclosed_recipients')
      expect(mail.cc).to be_nil
      expect(mail.bcc.size).to eq 1
      expect(mail.bcc).to include(@user2.email)
      expect(mail.subject).not_to be_empty
      expect(mail.body).not_to be_empty
      expect(mail.deliver_now).to eq mail
    end

    context 'uses Mailgun' do
      let(:recipient_variables) do
        @recipients.each_with_object({}) { |user, memo| memo[user.email] = { label: user.email } }
      end
      before { allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:mailgun) }

      it 'must create deliverable mail' do
        mail = SubscriptionsMailer.comment_created(@comment, @recipients)
        expect(mail.to.size).to eq 1
        expect(mail.to).to include(@user2.email)
        expect(mail.cc).to be_nil
        expect(mail.bcc.size).to eq 0
        expect(mail.subject).not_to be_empty
        expect(mail.body).not_to be_empty
        expect(mail.deliver_now).to eq mail
        expect(mail.mailgun_recipient_variables.size).to eq 1
      end
    end
  end
end

