require 'rails_helper'

RSpec.describe Commontator::Thread, type: :model do
  before { setup_model_spec }

  it 'must have a config' do
    expect(@thread.config).to be_a(Commontator::CommontableConfig)
    @thread.update_attribute(:commontable_id, nil)
    expect(Commontator::Thread.find(@thread.id).config).to eq Commontator
  end

  it 'must order all comments' do
    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!

    comments = @thread.comments
    ordered_comments = @thread.ordered_comments

    comments.each { |c| expect(ordered_comments).to include(c) }
    ordered_comments.each { |oc| expect(comments).to include(oc) }
  end

  it 'must list all subscribers' do
    @thread.subscribe(@user)
    @thread.subscribe(DummyUser.create)

    @thread.subscriptions.each do |sp|
      expect(@thread.subscribers).to include(sp.subscriber)
    end
  end

  it 'must find the subscription for each user' do
    @thread.subscribe(@user)
    user2 = DummyUser.create
    @thread.subscribe(user2)

    subscription = @thread.subscription_for(@user)
    expect(subscription.thread).to eq @thread
    expect(subscription.subscriber).to eq @user
    subscription = @thread.subscription_for(user2)
    expect(subscription.thread).to eq @thread
    expect(subscription.subscriber).to eq user2
  end

  it 'must know if it is closed' do
    expect(@thread.is_closed?).to eq false

    @thread.close(@user)

    expect(@thread.is_closed?).to eq true
    expect(@thread.closer).to eq @user

    @thread.reopen

    expect(@thread.is_closed?).to eq false
  end

  it 'must mark comments as read' do
    @thread.subscribe(@user)

    subscription = @thread.subscription_for(@user)
    expect(subscription.unread_comments.count).to eq 0

    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!

    expect(subscription.reload.unread_comments.count).to eq 1

    @thread.mark_as_read_for(@user)

    expect(subscription.reload.unread_comments.count).to eq 0
  end

  it 'must be able to clear comments' do
    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!

    @thread.close(@user)

    expect(@thread.commontable).to eq @commontable
    expect(@thread.comments).to include(comment)
    expect(@thread.is_closed?).to eq true
    expect(@thread.closer).to eq @user

    @commontable = DummyModel.find(@commontable.id)
    expect(@commontable.thread).to eq @thread

    @thread.clear

    expect(@thread.commontable).to be_nil
    expect(@thread.comments).to include(comment)

    @commontable = DummyModel.find(@commontable.id)
    expect(@commontable.thread).not_to be_nil
    expect(@commontable.thread).not_to eq @thread
    expect(@commontable.thread.comments).not_to include(comment)
  end

  it 'must preserve the thread and comments by default when commontable is gone' do
    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Undead'
    comment.save!
    comment.reload

    expect(described_class.find(@thread.id)).to eq @thread
    expect(Commontator::Comment.find(comment.id)).to eq comment

    @commontable.destroy!

    expect(described_class.find(@thread.id)).to eq @thread
    expect(Commontator::Comment.find(comment.id)).to eq comment
  end

  it 'must delete the thread and comments when commontable has dependent :destroy' do
    commontable = DummyDependentModel.create
    thread = commontable.thread

    comment = Commontator::Comment.new
    comment.thread = thread
    comment.creator = @user
    comment.body = 'Undead'
    comment.save!
    comment.reload

    expect(described_class.find(thread.id)).to eq thread
    expect(Commontator::Comment.find(comment.id)).to eq comment

    commontable.destroy!

    expect { described_class.find(thread.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    expect do
      Commontator::Comment.find(comment.id)
    end.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it 'must return nil subscription for nil or false subscriber' do
    expect(@thread.subscription_for(nil)).to eq nil
    expect(@thread.subscription_for(false)).to eq nil
  end
end
