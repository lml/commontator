require 'spec_helper'

describe Commontator::ThreadsController do
  before do
    setup_controller_spec
    @commontable_path = Rails.application.routes.url_helpers.dummy_model_path(@commontable)
  end
  
  it 'wont show unless authorized' do
    get :show, :id => @thread.id, :use_route => :commontator
    assert_response 403
    sign_in @user
    get :show, :id => @thread.id, :use_route => :commontator
    assert_response 403
  end
  
  it 'must show if authorized' do
    sign_in @user
    @user.can_read = true
    get :show, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @commontable_path
    @user.can_read = false
    @user.can_edit = true
    get :show, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @commontable_path
    @user.can_edit = false
    @user.is_admin = true
    get :show, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @commontable_path
  end
  
  it 'wont close unless authorized' do
    put :close, :id => @thread.id, :use_route => :commontator
    assert_response 403
    sign_in @user
    put :close, :id => @thread.id, :use_route => :commontator
    assert_response 403
    @user.can_read = true
    put :close, :id => @thread.id, :use_route => :commontator
    assert_response 403
  end
  
  it 'must close if authorized' do
    sign_in @user
    @user.can_edit = true
    put :close, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @thread
    @user.can_edit = false
    @user.is_admin = true
    put :close, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @thread
  end
  
  it 'wont reopen unless authorized' do
    @thread.close
    put :reopen, :id => @thread.id, :use_route => :commontator
    assert_response 403
    sign_in @user
    put :reopen, :id => @thread.id, :use_route => :commontator
    assert_response 403
    @user.can_read = true
    put :reopen, :id => @thread.id, :use_route => :commontator
    assert_response 403
  end
  
  it 'must reopen if authorized' do
    @thread.close
    sign_in @user
    @user.can_edit = true
    put :reopen, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @thread
    @user.can_edit = false
    @user.is_admin = true
    put :reopen, :id => @thread.id, :use_route => :commontator
    assert_redirected_to @thread
  end
end
