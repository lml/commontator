require 'test_helper'

class ThreadTest < ActiveSupport::TestCase

  test 'cannot mass-assign commentable, comments and subscriptions' do
    sq = FactoryGirl.create(:simple_question)
    c = [FactoryGirl.create(:comment)]
    cts = [FactoryGirl.create(:subscription)]
    ct = Commontator::Thread.new(:commentable => sq,
                           :comments => c,
                           :subscriptions => cts)
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
    ct = FactoryGirl.create(:thread)

    assert !ct.subscription_for(u)
    assert ct.subscribe!(u)
    assert ct.subscription_for(u)
    assert ct.subscribe!(u)
  end

  test 'unsubscribe' do
    u = FactoryGirl.create(:user)
    ct = FactoryGirl.create(:thread)

    assert !ct.unsubscribe!(u)
    assert ct.subscribe!(u)
    assert ct.subscription_for(u)
    assert ct.unsubscribe!(u)
    assert !ct.subscription_for(u)
  end

end
