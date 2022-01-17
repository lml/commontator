require 'rails_helper'

RSpec.describe Commontator::SubscriptionsController, type: :controller do
  routes { Commontator::Engine.routes }

  before { setup_controller_spec }

  context 'authorized' do
    before do
      @user.can_read = true
      Thread.current[:user] = @user
    end

    context 'PUT #subscribe' do
      it 'works' do
        put :subscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).not_to be_nil

        @thread.unsubscribe(@user)
        @user.can_read = false
        @user.can_edit = true
        put :subscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).not_to be_nil

        @thread.unsubscribe(@user)
        @user.can_edit = false
        @user.is_admin = true
        put :subscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).not_to be_nil
      end
    end

    context 'PUT #unsubscribe' do
      it 'works' do
        @thread.subscribe(@user)
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).to be_nil

        @thread.subscribe(@user)
        @user.can_read = false
        @user.can_edit = true
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).to be_nil

        @thread.subscribe(@user)
        @user.can_edit = false
        @user.is_admin = true
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).to be_empty
        expect(@thread.subscription_for(@user)).to be_nil
      end
    end
  end

  context 'unauthorized' do
    context 'PUT #subscribe' do
      it 'returns 403 Forbidden' do
        put :subscribe, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        expect(@thread.subscription_for(nil)).to be_nil
        expect(@thread.subscription_for(@user)).to be_nil

        Thread.current[:user] = @user
        put :subscribe, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        expect(@thread.subscription_for(@user)).to be_nil

        @thread.subscribe(@user)
        @user.can_read = true
        put :subscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).not_to be_empty
      end
    end

    context 'PUT #unsubscribe' do
      it 'returns 403 Forbidden' do
        @thread.subscribe(@user)
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        expect(@thread.subscription_for(nil)).to be_nil
        expect(@thread.subscription_for(@user)).not_to be_nil

        Thread.current[:user] = @user
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        expect(@thread.subscription_for(@user)).not_to be_nil

        @thread.unsubscribe(@user)
        @user.can_read = true
        put :unsubscribe, params: { id: @thread.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:commontator_thread).errors).not_to be_empty
      end
    end
  end
end
