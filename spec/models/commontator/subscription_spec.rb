require 'rails_helper'

RSpec.describe Commontator::Subscription, type: :model do
  before do
    setup_model_spec
    @subscription = described_class.new
    @subscription.thread = @thread
    @subscription.subscriber = @user
    @subscription.save!
  end

  it 'counts unread comments' do
    expect(@subscription.unread_comments(false).count).to eq 0

    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!

    expect(@subscription.reload.unread_comments(false).count).to eq 1

    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something else'
    comment.save!

    expect(@subscription.reload.unread_comments(false).count).to eq 2

    # Wait until 1 second after the comment was created
    sleep([1 - (Time.current - comment.created_at), 0].max)
    @subscription.touch

    expect(@subscription.reload.unread_comments(false).count).to eq 0
  end
end
