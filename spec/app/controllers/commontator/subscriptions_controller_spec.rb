require 'test_helper'

module Commontator
  describe SubscriptionsController do
    before do
      setup_controller_spec
    end
    
    it 'wont subscribe unless authorized' do
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).must_be_nil
      
      sign_in @user
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = true
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must subscribe if authorized' do
      sign_in @user
      
      @user.can_read = true
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      patch :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
    end
    
    it 'wont unsubscribe unless authorized' do
      @thread.subscribe(@user)
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).wont_be_nil
      
      sign_in @user
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = true
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must destroy if authorized' do
      sign_in @user
      
      @thread.subscribe(@user)
      @user.can_read = true
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      patch :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
    end
  end
end
