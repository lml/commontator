require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test 'one subscription per user per thread' do
    u = FactoryGirl.create(:user)
    ct = FactoryGirl.create(:thread)
    cts0 = Subscription.create(:user => u, :thread => ct)
    cts1 = Subscription.new(:user => u, :thread => ct)
    assert !cts1.save
    cts0.destroy
    cts1.save!
  end

end
