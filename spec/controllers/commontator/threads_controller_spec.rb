require 'rails_helper'

module Commontator
  RSpec.describe ThreadsController, type: :controller do
    routes { Commontator::Engine.routes }

    before(:each) do
      setup_controller_spec
    end
    
    it "won't show unless authorized" do
      get :show, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      
      sign_in @user
      get :show, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
    end
    
    it 'must show if authorized' do
      commontable_path = Rails.application.routes.url_helpers.dummy_model_path(@commontable)
      sign_in @user
      
      @user.can_read = true
      get :show, :id => @thread.id
      expect(response).to redirect_to(commontable_path)
      
      @user.can_read = false
      @user.can_edit = true
      get :show, :id => @thread.id
      expect(response).to redirect_to(commontable_path)
      
      @user.can_edit = false
      @user.is_admin = true
      get :show, :id => @thread.id
      expect(response).to redirect_to(commontable_path)
    end
    
    it "won't close unless authorized and open" do
      put :close, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false
      
      sign_in @user
      put :close, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false
      
      @user.can_read = true
      put :close, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false
      
      @user.can_edit = true
      expect(@thread.close).to eq true
      put :close, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end
    
    it 'must close if authorized and open' do
      sign_in @user
      
      @user.can_edit = true
      put :close, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq true
      expect(assigns(:thread).closer).to eq @user
      
      expect(assigns(:thread).reopen).to eq true
      @user.can_edit = false
      @user.is_admin = true
      put :close, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq true
      expect(assigns(:thread).closer).to eq @user
    end
    
    it "won't reopen unless authorized and closed" do
      expect(@thread.close).to eq true
      put :reopen, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true
      
      sign_in @user
      put :reopen, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true
      
      @user.can_read = true
      put :reopen, :id => @thread.id
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true
      
      expect(@thread.reopen).to eq true
      @user.can_edit = true
      put :reopen, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end
    
    it 'must reopen if authorized and closed' do
      sign_in @user
      
      expect(@thread.close).to eq true
      @user.can_edit = true
      put :reopen, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq false
      
      expect(assigns(:thread).close).to eq true
      @user.can_edit = false
      @user.is_admin = true
      put :reopen, :id => @thread.id
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq false
    end
  end
end

