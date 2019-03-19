require 'rails_helper'
require 'acts_as_votable'

module Commontator
  RSpec.describe Comment, type: :model do
    before(:each) do
      setup_model_spec
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
    end

    it 'must be votable if acts_as_votable is installed' do
      expect(Comment).to respond_to(:acts_as_votable)
      expect(@comment.is_votable?).to eq true
      expect(@comment.acts_as_votable_initialized).to eq true
    end

    it 'must know if it has been modified' do
      @comment.save!

      expect(@comment.is_modified?).to eq false

      @comment.body = 'Something else'
      @comment.editor = @user
      @comment.save!

      expect(@comment.is_modified?).to eq true
    end

    it 'must know if it has been deleted' do
      user = DummyUser.new

      expect(@comment.is_deleted?).to eq false
      expect(@comment.editor).to be_nil

      @comment.delete_by(user)

      expect(@comment.is_deleted?).to eq true
      expect(@comment.editor).to eq user

      @comment.undelete_by(user)

      expect(@comment.is_deleted?).to eq false
    end
  end
end

