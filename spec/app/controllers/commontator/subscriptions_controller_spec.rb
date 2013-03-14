require 'minitest_helper'

module Commontator
  describe SubscriptionsController do
    before do
      setup_controller_spec
    end
    
    it 'wont create unless authorized' do
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).must_be_nil
      
      sign_in @user
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = true
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must create if authorized' do
      sign_in @user
      
      @user.can_read = true
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      post :create, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
    end
    
    it 'wont destroy unless authorized' do
      @thread.subscribe(@user)
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).wont_be_nil
      
      sign_in @user
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = true
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must destroy if authorized' do
      sign_in @user
      
      @thread.subscribe(@user)
      @user.can_read = true
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      delete :destroy, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
    end
  end
end
