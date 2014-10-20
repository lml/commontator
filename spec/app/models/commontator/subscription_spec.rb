require 'spec_helper'

module Commontator
  describe Subscription do
    before do
      setup_model_spec
      @subscription = Subscription.new
      @subscription.thread = @thread
      @subscription.subscriber = @user
      @subscription.save!
    end
    
    it 'must count unread comments' do
      @subscription.unread_comments.count.must_equal 0
      
      comment = Comment.new
      comment.thread = @thread
      comment.creator = @user
      comment.body = 'Something'
      comment.save!
      
      @subscription.reload.unread_comments.count.must_equal 1
      
      comment = Comment.new
      comment.thread = @thread
      comment.creator = @user
      comment.body = 'Something else'
      comment.save!
      
      @subscription.reload.unread_comments.count.must_equal 2
      
      @subscription.touch
      
      @subscription.reload.unread_comments.count.must_equal 0
    end
  end
end
