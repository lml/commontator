require 'spec_helper'

describe Commontator::Subscription do
  before do
    setup_spec_variables
    @subscription = Commontator::Subscription.new
    @subscription.thread = @thread
    @subscription.subscriber = @user
  end
  
  it 'must count unread comments' do
    @subscription.unread.must_equal 0
    
    @subscription.add_unread
    
    @subscription.unread.must_equal 1
    
    @subscription.add_unread
    
    @subscription.unread.must_equal 2
    
    @subscription.mark_as_read
    
    @subscription.unread.must_equal 0
  end
end
