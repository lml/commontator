require 'spec_helper'

module Commontator
  describe SubscriptionsMailer do
    before do
      setup_mailer_spec
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
      @comment.save!
      @commontable_url = 'dummy_model_url'
      @thread.subscribe(@user)
    end
    
    it 'wont send email if subscribers empty' do
      mail = SubscriptionsMailer.comment_created_email(@comment, @commontable_url)
      mail.to.must_be_nil
      mail.cc.must_be_nil
      mail.bcc.must_be_nil
      mail.subject.must_be_nil
      mail.body.must_be_empty
    end
    
    it 'must send email if subscribers not empty' do
      user2 = DummyUser.create
      @thread.subscribe(DummyUser.create)
      mail = SubscriptionsMailer.comment_created_email(@comment, @commontable_url)
      mail.to.must_be_nil
      mail.cc.must_be_nil
      mail.bcc.size.must_equal 1
      mail.bcc.must_include user2.email
      mail.subject.wont_be_empty
      mail.body.wont_be_empty
    end
    
  end
end
