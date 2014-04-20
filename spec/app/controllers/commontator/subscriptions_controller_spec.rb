require 'spec_helper'

module Commontator
  describe SubscriptionsController do
    before do
      setup_controller_spec
    end
    
    it "won't subscribe unless authorized" do
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).must_be_nil
      
      sign_in @user
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = true
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must subscribe if authorized' do
      sign_in @user
      
      @user.can_read = true
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      put :subscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).wont_be_nil
    end
    
    it "won't unsubscribe unless authorized" do
      @thread.subscribe(@user)
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(nil).must_be_nil
      @thread.subscription_for(@user).wont_be_nil
      
      sign_in @user
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_response 403
      @thread.subscription_for(@user).wont_be_nil
      
      @thread.unsubscribe(@user)
      @user.can_read = true
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must unsubscribe if authorized' do
      sign_in @user
      
      @thread.subscribe(@user)
      @user.can_read = true
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
      
      @thread.subscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      put :unsubscribe, :thread_id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      @thread.subscription_for(@user).must_be_nil
    end
  end
end

