# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

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
