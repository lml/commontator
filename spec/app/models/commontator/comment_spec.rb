require 'test_helper'
require 'acts_as_votable'

module Commontator
  describe Comment do
    before do
      setup_model_spec
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
    end
    
    it 'must be votable if acts_as_votable is installed' do
      Comment.must_respond_to(:acts_as_votable)
      @comment.is_votable?.must_equal true
      @comment.acts_as_votable_initialized.must_equal true
    end
    
    it 'must know if it has been modified' do
      @comment.save!
      
      @comment.is_modified?.must_equal false
      
      @comment.body = 'Something else'
      @comment.editor = @user
      @comment.save!
      
      @comment.is_modified?.must_equal true
    end
    
    it 'must know if it has been deleted' do
      user = DummyUser.new
      
      @comment.is_deleted?.must_equal false
      @comment.editor.must_be_nil
      
      @comment.delete_by(user)
      
      @comment.is_deleted?.must_equal true
      @comment.editor.must_equal user
      
      @comment.undelete_by(user)
      
      @comment.is_deleted?.must_equal false
    end
  end
end
