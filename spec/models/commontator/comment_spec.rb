require 'rails_helper'
require 'acts_as_votable'

RSpec.describe Commontator::Comment, type: :model do
  before do
    setup_model_spec
    @comment = described_class.new
    @comment.thread = @thread
    @comment.creator = @user
    @comment.body = 'Something'
  end

  it 'is votable if acts_as_votable is installed' do
    expect(described_class).to respond_to(:acts_as_votable)
    expect(described_class.is_votable?).to eq true
  end

  it 'knows if it has been modified' do
    @comment.save!

    expect(@comment.is_modified?).to eq false

    @comment.body = 'Something else'
    @comment.editor = @user
    @comment.save!

    expect(@comment.is_modified?).to eq true
  end

  it 'knows if it has been deleted' do
    user = DummyUser.new

    expect(@comment.is_deleted?).to eq false
    expect(@comment.editor).to be_nil

    @comment.delete_by(user)

    expect(@comment.is_deleted?).to eq true
    expect(@comment.editor).to eq user

    @comment.undelete_by(user)

    expect(@comment.is_deleted?).to eq false
  end

  it 'makes proper timestamps' do
    @comment.save!

    expect(@comment.created_timestamp).to eq(
      I18n.t('commontator.comment.status.created_at',
             created_at: I18n.l(@comment.created_at, format: :commontator))
    )
    expect(@comment.updated_timestamp).to eq(
      I18n.t('commontator.comment.status.updated_at',
             editor_name: @user.name,
             updated_at: I18n.l(@comment.updated_at, format: :commontator))
    )

    user2 = DummyUser.create
    @comment.body = 'Something else'
    @comment.editor = user2
    @comment.save!

    expect(@comment.created_timestamp).to eq(
      I18n.t('commontator.comment.status.created_at',
             created_at: I18n.l(@comment.created_at, format: :commontator))
    )
    expect(@comment.updated_timestamp).to eq(
      I18n.t('commontator.comment.status.updated_at',
             editor_name: user2.name,
             updated_at: I18n.l(@comment.updated_at, format: :commontator))
    )
  end
end
