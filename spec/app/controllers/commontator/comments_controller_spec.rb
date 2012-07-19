require 'spec_helper'

describe Commontator::CommentsController do
  before do
    setup_controller_spec
    @comment = Commontator::Comment.new
    @comment.thread = @thread
    @comment.creator = @user
    @comment.body = 'Something'
    @comment.save!
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
    attributes[:body] = 'Something'
    
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
    attributes[:body] = 'Something'
    
    @user.can_read = true
    post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).body.must_equal 'Something'
    assigns(:comment).creator.must_equal @user
    assigns(:comment).thread.must_equal @thread
    
    @user.can_read = false
    @user.can_edit = true
    post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).body.must_equal 'Something'
    assigns(:comment).creator.must_equal @user
    assigns(:comment).thread.must_equal @thread
    
    @user.can_edit = false
    @user.is_admin = true
    post :create, :thread_id => @thread.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).body.must_equal 'Something'
    assigns(:comment).creator.must_equal @user
    assigns(:comment).thread.must_equal @thread
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
    comment2 = Commontator::Comment.new
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
    
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_response 403
    assigns(:comment).body.must_equal 'Something'
    
    sign_in @user
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_response 403
    assigns(:comment).body.must_equal 'Something'
    
    user2 = DummyUser.create
    user2.can_read = true
    user2.can_edit = true
    user2.is_admin = true
    sign_in user2
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_response 403
    assigns(:comment).body.must_equal 'Something'
    
    @user.can_read = true
    @user.can_edit = true
    @user.is_admin = true
    sign_in @user
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_response 403
    assigns(:comment).body.must_equal 'Something'
  end
  
  it 'must update if authorized' do
    sign_in @user
    attributes = Hash.new
    attributes[:body] = 'Something else'
    
    @user.can_read = true
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    
    @user.can_read = false
    @user.can_edit = true
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    
    @user.can_edit = false
    @user.is_admin = true
    put :update, :id => @comment.id, :comment => attributes, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
  end
  
  it 'wont delete unless authorized and not deleted' do
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal false
    
    sign_in @user
    
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal false
    
    @user.can_read = true
    @comment.delete(@user).must_equal true
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.wont_be_empty
    
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!
    @comment.undelete.must_equal true
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal false
  end
  
  it 'must delete if authorized and not deleted' do
    sign_in @user
    
    @user.can_read = true
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal true
    assigns(:comment).deleter.must_equal @user
    
    user2 = DummyUser.create
    sign_in user2
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!
    
    assigns(:comment).undelete.must_equal true
    user2.can_edit = true
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal true
    assigns(:comment).deleter.must_equal user2
    
    assigns(:comment).undelete.must_equal true
    user2.can_edit = false
    user2.is_admin = true
    put :delete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal true
    assigns(:comment).deleter.must_equal user2
  end
  
  it 'wont undelete unless authorized and deleted' do
    @comment.delete(@user).must_equal true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal true
    
    sign_in @user
    
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal true
    
    @user.can_read = true
    @comment.undelete.must_equal true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.wont_be_empty
    
    @comment.delete.must_equal true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal true
    
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!
    @comment.undelete.must_equal true
    @comment.delete(@user).must_equal true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_response 403
    assigns(:comment).is_deleted?.must_equal true
  end
  
  it 'must undelete if authorized and deleted' do
    sign_in @user
    
    @comment.delete(@user).must_equal true
    @user.can_read = true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal false
    
    user2 = DummyUser.create
    sign_in user2
    comment2 = Commontator::Comment.new
    comment2.thread = @thread
    comment2.creator = @user
    comment2.body = 'Something else'
    comment2.save!
    
    assigns(:comment).delete(@user).must_equal true
    user2.can_edit = true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal false
    
    assigns(:comment).delete(@user).must_equal true
    user2.can_edit = false
    user2.is_admin = true
    put :undelete, :id => @comment.id, :use_route => :commontator
    assert_redirected_to @thread
    assigns(:comment).errors.must_be_empty
    assigns(:comment).is_deleted?.must_equal false
  end
  
  it 'wont let comment thread or creator be mass-assigned' do
    sign_in @user
    @user.can_read = true
    
    lambda {post :create, :thread_id => @thread.id, :comment => @comment.attributes, :use_route => :commontator} \
      .must_raise ActiveModel::MassAssignmentSecurity::Error
    
    lambda {put :update, :id => @comment.id, :comment => @comment.attributes, :use_route => :commontator} \
      .must_raise ActiveModel::MassAssignmentSecurity::Error
  end
end
