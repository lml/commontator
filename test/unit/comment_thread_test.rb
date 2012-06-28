# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class CommentThreadTest < ActiveSupport::TestCase

  test 'cannot mass-assign commentable, comments and comment_thread_subscriptions' do
    sq = FactoryGirl.create(:simple_question)
    c = [FactoryGirl.create(:comment)]
    cts = [FactoryGirl.create(:comment_thread_subscription)]
    ct = CommentThread.new(:commentable => sq,
                           :comments => c,
                           :comment_thread_subscriptions => cts)
    assert ct.commentable != sq
    assert ct.comments != c
    assert ct.comment_thread_subscriptions != cts
  end

  test 'clear' do
    u = FactoryGirl.create(:user)
    q = FactoryGirl.create(:simple_question)
    ct = q.comment_thread
    c = Comment.new
    c.comment_thread = ct
    c.creator = u
    c.save!

    assert !q.comment_thread.comments.empty?
    assert_equal q.comment_thread, ct

    ct.clear!
    q.reload

    assert q.comment_thread.comments.empty?
    assert q.comment_thread != ct
  end

  test 'subscribe' do
    u = FactoryGirl.create(:user)
    ct = FactoryGirl.create(:comment_thread)

    assert !ct.subscription_for(u)
    assert ct.subscribe!(u)
    assert ct.subscription_for(u)
    assert ct.subscribe!(u)
  end

  test 'unsubscribe' do
    u = FactoryGirl.create(:user)
    ct = FactoryGirl.create(:comment_thread)

    assert !ct.unsubscribe!(u)
    assert ct.subscribe!(u)
    assert ct.subscription_for(u)
    assert ct.unsubscribe!(u)
    assert !ct.subscription_for(u)
  end

end
