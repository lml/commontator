require 'test_helper'
require 'acts_as_votable'

module Commontator
  describe CommentsController do
    before do
      setup_controller_spec
      @comment = Comment.new
      @comment.thread = @thread
      @comment.creator = @user
      @comment.body = 'Something'
      @comment.save!
      @comment.is_votable?.must_equal true
    end
    
    it 'wont get new unless authorized' do
      get :new, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      
      sign_in @user
      get :new, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
    end
    
    it 'must get new if authorized' do
      sign_in @user
      
      @user.can_read = true
      get :new, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      
      @user.can_read = false
      @user.can_edit = true
      get :new, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      
      @user.can_edit = false
      @user.is_admin = true
      get :new, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
    end
    
    it 'wont create unless authorized' do
      attributes = Hash.new
      attributes[:body] = 'Something else'
      
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      
      sign_in @user
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      
      @user.can_read = true
      @user.can_edit = true
      @user.is_admin = true
      @thread.close.must_equal true
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_response 403
    end
    
    it 'must create if authorized' do
      sign_in @user
      attributes = Hash.new
      
      attributes[:body] = 'Something else'
      @user.can_read = true
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).body.must_equal 'Something else'
      assigns(:comment).creator.must_equal @user
      assigns(:comment).editor.must_be_nil
      assigns(:comment).thread.must_equal @thread
      
      attributes[:body] = 'Another thing'
      @user.can_read = false
      @user.can_edit = true
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).body.must_equal 'Another thing'
      assigns(:comment).creator.must_equal @user
      assigns(:comment).editor.must_be_nil
      assigns(:comment).thread.must_equal @thread
      
      attributes[:body] = 'And this too'
      @user.can_edit = false
      @user.is_admin = true
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).body.must_equal 'And this too'
      assigns(:comment).creator.must_equal @user
      assigns(:comment).editor.must_be_nil
      assigns(:comment).thread.must_equal @thread
    end
    
    it 'wont create if double posting' do
      sign_in @user
      @user.can_read = true
      attributes = Hash.new
      
      attributes[:body] = 'Something'
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.wont_be_empty
      
      attributes[:body] = 'Something else'
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).body.must_equal 'Something else'
      assigns(:comment).creator.must_equal @user
      assigns(:comment).editor.must_be_nil
      assigns(:comment).thread.must_equal @thread
      
      attributes[:body] = 'Something else'
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.wont_be_empty
    end
    
    it 'wont edit unless authorized' do
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_response 403
      
      sign_in @user
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_response 403
      
      user2 = DummyUser.create
      user2.can_read = true
      user2.can_edit = true
      user2.is_admin = true
      sign_in user2
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_response 403
      
      @user.can_read = true
      @user.can_edit = true
      @user.is_admin = true
      sign_in @user
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_response 403
    end
    
    it 'must edit if authorized' do
      sign_in @user
      
      @user.can_read = true
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      
      @user.can_read = false
      @user.can_edit = true
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      
      @user.can_edit = false
      @user.is_admin = true
      get :edit, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
    end
    
    it 'wont update unless authorized' do
      attributes = Hash.new
      attributes[:body] = 'Something else'
      
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      assigns(:comment).body.must_equal 'Something'
      assigns(:comment).editor.must_be_nil
      
      sign_in @user
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      assigns(:comment).body.must_equal 'Something'
      assigns(:comment).editor.must_be_nil
      
      user2 = DummyUser.create
      user2.can_read = true
      user2.can_edit = true
      user2.is_admin = true
      sign_in user2
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      assigns(:comment).body.must_equal 'Something'
      assigns(:comment).editor.must_be_nil
      
      @user.can_read = true
      @user.can_edit = true
      @user.is_admin = true
      sign_in @user
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_response 403
      assigns(:comment).body.must_equal 'Something'
      assigns(:comment).editor.must_be_nil
    end
    
    it 'must update if authorized' do
      sign_in @user
      attributes = Hash.new
      attributes[:body] = 'Something else'
      
      @user.can_read = true
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).editor.must_equal @user
      
      @user.can_read = false
      @user.can_edit = true
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).editor.must_equal @user
      
      @user.can_edit = false
      @user.is_admin = true
      patch :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).editor.must_equal @user
    end
    
    it 'wont delete unless authorized and not deleted' do
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal false
      
      sign_in @user
      
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal false
      
      @user.can_read = true
      @comment.delete_by(@user).must_equal true
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.wont_be_empty
      
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      @comment.undelete_by(@user).must_equal true
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal false
    end
    
    it 'must delete if authorized and not deleted' do
      sign_in @user
      
      @user.can_read = true
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal true
      assigns(:comment).editor.must_equal @user
      
      user2 = DummyUser.create
      sign_in user2
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      
      assigns(:comment).undelete_by(@user).must_equal true
      user2.can_edit = true
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal true
      assigns(:comment).editor.must_equal user2
      
      assigns(:comment).undelete_by(@user).must_equal true
      user2.can_edit = false
      user2.is_admin = true
      patch :delete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal true
      assigns(:comment).editor.must_equal user2
    end
    
    it 'wont undelete unless authorized and deleted' do
      @comment.delete_by(@user).must_equal true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal true
      
      sign_in @user
      
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal true
      
      @user.can_read = true
      @comment.undelete_by(@user).must_equal true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.wont_be_empty
      
      user2 = DummyUser.create
      user2.can_read = true
      user2.can_edit = true
      user2.is_admin = true
      @comment.delete_by(user2).must_equal true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal true
      
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      @comment.undelete_by(@user).must_equal true
      @comment.delete_by(@user).must_equal true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).is_deleted?.must_equal true
    end
    
    it 'must undelete if authorized and deleted' do
      sign_in @user
      
      @comment.delete_by(@user).must_equal true
      @user.can_read = true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal false
      
      user2 = DummyUser.create
      sign_in user2
      comment2 = Comment.new
      comment2.thread = @thread
      comment2.creator = @user
      comment2.body = 'Something else'
      comment2.save!
      
      assigns(:comment).delete_by(@user).must_equal true
      user2.can_edit = true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal false
      
      assigns(:comment).delete_by(@user).must_equal true
      user2.can_edit = false
      user2.is_admin = true
      patch :undelete, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).errors.must_be_empty
      assigns(:comment).is_deleted?.must_equal false
    end
    
    it 'wont upvote if not authorized' do
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      sign_in @user
      @user.can_read = true
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      user2 = DummyUser.create
      sign_in user2
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
    end
    
    it 'must upvote if authorized' do
      user2 = DummyUser.create
      user2.can_read = true
      sign_in user2
      
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
      
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
      
      @comment.downvote_from(user2).must_equal true
      
      patch :upvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
    end
    
    it 'wont downvote if not authorized' do
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      sign_in @user
      @user.can_read = true
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      user2 = DummyUser.create
      sign_in user2
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
    end
    
    it 'must downvote if authorized' do
      user2 = DummyUser.create
      user2.can_read = true
      sign_in user2
      
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.count.must_equal 1
      
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.count.must_equal 1
      
      @comment.upvote_from(user2).must_equal true
      
      patch :downvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.count.must_equal 1
    end
    
    it 'wont unvote if not authorized' do
      @comment.upvote_from(@user).must_equal true
      
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
      
      sign_in @user
      @user.can_read = true
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
      
      user2 = DummyUser.create
      sign_in user2
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_response 403
      assigns(:comment).upvotes.count.must_equal 1
      assigns(:comment).downvotes.must_be_empty
    end
    
    it 'must unvote if authorized' do
      user2 = DummyUser.create
      user2.can_read = true
      sign_in user2
      
      @comment.upvote_from(user2).must_equal true
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
      
      @comment.downvote_from(user2).must_equal true
      patch :unvote, :id => @comment.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:comment).upvotes.must_be_empty
      assigns(:comment).downvotes.must_be_empty
    end

    it 'wont send mail if recipients empty' do
      if defined?(CommentsController::SubscriptionsMailer)
        CommentsController::SubscriptionsMailer.__send__(:initialize)
      else
        CommentsController::SubscriptionsMailer = MiniTest::Mock.new
      end

      user2 = DummyUser.create
      user2.can_read = true

      email = MiniTest::Mock.new.expect(:deliver, nil)
      CommentsController::SubscriptionsMailer.expect(:comment_created, email, [Comment, [user2]])

      @user.can_read = true
      sign_in @user

      attributes = {:body => 'Something else'}
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assigns(:comment).errors.must_be_empty

      proc { CommentsController::SubscriptionsMailer.verify }.must_raise(MockExpectationError)
      proc { email.verify }.must_raise(MockExpectationError)
    end
    
    it 'must send mail if recipients not empty' do
      if defined?(CommentsController::SubscriptionsMailer)
        CommentsController::SubscriptionsMailer.__send__(:initialize)
      else
        CommentsController::SubscriptionsMailer = MiniTest::Mock.new
      end

      user2 = DummyUser.create
      user2.can_read = true
      @thread.subscribe(user2)

      email = MiniTest::Mock.new.expect(:deliver, nil)
      CommentsController::SubscriptionsMailer.expect(:comment_created, email, [Comment, [user2]])

      @user.can_read = true
      sign_in @user

      attributes = {:body => 'Something else'}
      post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
      assigns(:comment).errors.must_be_empty

      CommentsController::SubscriptionsMailer.verify
      email.verify
    end
  end
end
