require 'test_helper'

class CommentThreadSubscriptionTest < ActiveSupport::TestCase

  test 'one comment_thread_subscription per user per thread' do
    u = FactoryGirl.create(:user)
    ct = FactoryGirl.create(:comment_thread)
    cts0 = CommentThreadSubscription.create(:user => u, :comment_thread => ct)
    cts1 = CommentThreadSubscription.new(:user => u, :comment_thread => ct)
    assert !cts1.save
    cts0.destroy
    cts1.save!
  end

end
