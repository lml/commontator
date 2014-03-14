require 'test_helper'

module Commontator
  describe SubscriptionsMailer do
    before do
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
      mail = SubscriptionsMailer.comment_created(@comment, @recipients)
      mail.must_be_instance_of Mail::Message
      mail.to.must_equal I18n.t('commontator.email.undisclosed_recipients')
      mail.cc.must_be_nil
      mail.bcc.size.must_equal 1
      mail.bcc.must_include @user2.email
      mail.subject.wont_be_empty
      mail.body.wont_be_empty
      mail.deliver.must_equal mail
    end
  end
end
