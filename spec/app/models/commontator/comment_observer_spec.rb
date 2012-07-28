require 'spec_helper'

module Commontator
  describe CommentObserver do
    before do
      setup_model_spec
      @comment_observer = CommentObserver.instance
      @thread.subscribe(@user)
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
      @comment.save!
    end
    
    it 'wont send mail unless recipients not empty' do
      @comment_observer.after_create(@comment).must_be_nil
    end
    
    it 'must send mail if recipients not empty' do
      @user2 = DummyUser.create
      @thread.subscribe(@user2)
      @comment.reload
      @comment_observer.after_create(@comment).must_be_instance_of Mail::Message
    end
  end
end
