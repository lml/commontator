require 'rails_helper'

RSpec.describe Commontator::Thread, type: :model do
  before { setup_model_spec }

  it 'has a config' do
    expect(@thread.config).to be_a(Commontator::CommontableConfig)
    @thread.update_attribute(:commontable_id, nil)
    expect(Commontator::Thread.find(@thread.id).config).to eq Commontator
  end

  it 'filters comments' do
    expect(@thread.config).to receive(:comment_filter).and_return(
      Commontator::Comment.arel_table[:deleted_at].eq(nil)
    )
    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!
    comment.delete_by @user

    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!

    comments = [ comment, comment2 ]
    all_comments = @thread.filtered_comments(true)
    expect(comments - all_comments).to be_empty
    expect(all_comments - comments).to be_empty

    filtered_comments = @thread.filtered_comments(false)
    expect(comments - filtered_comments).to eq [ comment ]
    expect(filtered_comments - comments).to be_empty
  end

  it 'orders comments' do
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

    comments = [ comment, comment2 ]
    ordered_comments = @thread.ordered_comments(true)
    expect(comments - ordered_comments).to be_empty
    expect(ordered_comments - comments).to be_empty
    expect(ordered_comments).to eq comments.sort_by(&:created_at)
  end

  it 'paginates comments' do
    expect(@thread.config).to receive(:comments_per_page).twice.and_return([ 2 ])

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

    comment3 = Commontator::Comment.new
    comment3.thread = @thread
    comment3.creator = @user
    comment3.body = 'Another thing'
    comment3.save!

    expect(@thread.paginated_comments(1, nil, true)).to eq [ comment, comment2 ]
    expect(@thread.paginated_comments(2, nil, true)).to eq [ comment3 ]
  end

  [ :n, :q, :i, :b ].each do |comment_reply_style|
    context "comment_reply_style #{comment_reply_style}" do
      before do
        expect(@thread.config).to(
          receive(:comment_reply_style).at_least(:once).and_return(comment_reply_style)
        )
      end

      it [ :n, :q ].include?(comment_reply_style) ?
           'ignores comment parent_ids' : 'returns comments with a given parent_id' do
        comment = Commontator::Comment.new
        comment.thread = @thread
        comment.creator = @user
        comment.body = 'Something'
        comment.save!

        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.parent = comment
        comment2.save!

        comment3 = Commontator::Comment.new
        comment3.thread = @thread
        comment3.creator = @user
        comment3.body = 'Another thing'
        comment3.save!

        expect(@thread.comments_with_parent_id(comment.id, true)).to eq(
          [ :n, :q ].include?(comment_reply_style) ? [ comment, comment2, comment3 ] : [ comment2 ]
        )
      end

      it "#{ [ :n, :q ].include?(comment_reply_style) ? 'does not nest' : 'nests' } comments" do
        expect(@thread.config).to receive(:comments_per_page).at_least(:twice).and_return([ 2, 1 ])

        comment = Commontator::Comment.new
        comment.thread = @thread
        comment.creator = @user
        comment.body = 'Something'
        comment.save!

        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.parent = comment
        comment2.save!

        comment3 = Commontator::Comment.new
        comment3.thread = @thread
        comment3.creator = @user
        comment3.body = 'Another thing'
        comment3.parent = comment
        comment3.save!

        comments = @thread.paginated_comments(1, nil, true)
        expect(@thread.nested_comments_for(@user, comments, true)).to eq(
          [ :n, :q ].include?(comment_reply_style) ?
            [ [ comment, [] ], [ comment2, [] ] ] : [ [ comment, [ [ comment2, [] ] ] ] ]
        )
      end
    end
  end

  it 'allows users to subscribe to the thread' do
    @thread.subscribe(@user)
    @thread.subscribe(DummyUser.create)

    @thread.subscriptions.each do |sp|
      expect(@thread.subscribers).to include(sp.subscriber)
    end
  end

  it 'finds the subscription for each user' do
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

  it 'returns nil subscription for nil or false subscriber' do
    expect(@thread.subscription_for(nil)).to eq nil
    expect(@thread.subscription_for(false)).to eq nil
  end

  it 'knows if it is closed' do
    expect(@thread.is_closed?).to eq false

    @thread.close(@user)

    expect(@thread.is_closed?).to eq true
    expect(@thread.closer).to eq @user

    @thread.reopen

    expect(@thread.is_closed?).to eq false
  end

  it 'marks comments as read' do
    @thread.subscribe(@user)

    subscription = @thread.subscription_for(@user)
    expect(subscription.unread_comments(false).count).to eq 0

    comment = Commontator::Comment.new
    comment.thread = @thread
    comment.creator = @user
    comment.body = 'Something'
    comment.save!

    expect(subscription.reload.unread_comments(false).count).to eq 1

    # Wait until 1 second after the comment was created
    sleep([1 - (Time.current - comment.created_at), 0].max)
    @thread.mark_as_read_for(@user)

    expect(subscription.reload.unread_comments(false).count).to eq 0
  end

  it 'can clear comments' do
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
    expect(@commontable.commontator_thread).to eq @thread

    @thread.clear

    expect(@thread.commontable).to be_nil
    expect(@thread.comments).to include(comment)

    @commontable = DummyModel.find(@commontable.id)
    expect(@commontable.commontator_thread).not_to be_nil
    expect(@commontable.commontator_thread).not_to eq @thread
    expect(@commontable.commontator_thread.comments).not_to include(comment)
  end

  it 'preserves the thread and comments by default when the commontable is gone' do
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

  it 'deletes the thread and comments when commontable has dependent :destroy' do
    commontable = DummyDependentModel.create
    thread = commontable.commontator_thread

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
end
