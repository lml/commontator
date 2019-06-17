require 'rails_helper'

RSpec.describe Commontator::ThreadsController, type: :controller do
  routes { Commontator::Engine.routes }

  before { setup_controller_spec }

  context 'authorized' do
    before do
      @user.can_read = true
      controller.current_user = @user
    end

    context 'GET #show' do
      it 'works' do
        commontable_path = Rails.application.routes.url_helpers.dummy_model_path(@commontable)

        get :show, params: { id: @thread.id }
        expect(response).to redirect_to(commontable_path)

        @user.can_read = false
        @user.can_edit = true
        get :show, params: { id: @thread.id }
        expect(response).to redirect_to(commontable_path)

        @user.can_edit = false
        @user.is_admin = true
        get :show, params: { id: @thread.id }
        expect(response).to redirect_to(commontable_path)
      end
    end

    context 'open' do
      context 'PUT #close' do
        it 'works' do
          @user.can_edit = true
          put :close, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).to be_empty
          expect(assigns(:thread).is_closed?).to eq true
          expect(assigns(:thread).closer).to eq @user

          expect(assigns(:thread).reopen).to eq true
          @user.can_edit = false
          @user.is_admin = true
          put :close, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).to be_empty
          expect(assigns(:thread).is_closed?).to eq true
          expect(assigns(:thread).closer).to eq @user
        end
      end

      context 'PUT #reopen' do
        it 'redirects to the thread and returns an error message' do
          @user.can_edit = true
          put :reopen, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).not_to be_empty
          expect(assigns(:thread).is_closed?).to eq false
          expect(assigns(:thread).closer).to be_nil

          @user.can_edit = false
          @user.is_admin = true
          put :reopen, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).not_to be_empty
          expect(assigns(:thread).is_closed?).to eq false
          expect(assigns(:thread).closer).to be_nil
        end
      end
    end

    context 'closed' do
      before { expect(@thread.close).to eq true }

      context 'PUT #reopen' do
        it 'works' do
          @user.can_edit = true
          put :reopen, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).to be_empty
          expect(assigns(:thread).is_closed?).to eq false

          expect(assigns(:thread).close).to eq true
          @user.can_edit = false
          @user.is_admin = true
          put :reopen, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).to be_empty
          expect(assigns(:thread).is_closed?).to eq false
        end
      end

      context 'PUT #close' do
        it 'redirects to the thread and returns an error message' do
          @user.can_edit = true
          put :close, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).not_to be_empty
          expect(assigns(:thread).is_closed?).to eq true
          expect(assigns(:thread).closer).to be_nil

          @user.can_edit = false
          @user.is_admin = true
          put :close, params: { id: @thread.id }
          expect(response).to redirect_to(@thread)
          expect(assigns(:thread).errors).not_to be_empty
          expect(assigns(:thread).is_closed?).to eq true
          expect(assigns(:thread).closer).to be_nil
        end
      end
    end

    context 'GET #mentions' do
      let(:search_phrase) { nil }
      let(:call_request)  do
        get :mentions, params: { id: @thread.id, format: :json, q: search_phrase }
      end

      let!(:other_user)   { DummyUser.create }

      context 'mentions enabled' do
        context 'query is blank' do
          it 'returns a JSON error message' do
            call_request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['errors']).to(
              include('Query string is too short (minimum 3 characters)')
            )
          end
        end

        context 'query is too short' do
          let(:search_phrase) { 'Us' }

          it 'returns a JSON error message' do
            call_request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['errors']).to(
              include('Query string is too short (minimum 3 characters)')
            )
          end
        end

        context 'query is 3 characters or more' do
          let(:search_phrase) { 'User' }

          let(:valid_result) { [@user] }
          let(:valid_response) do
            {
              'mentions' => valid_result.map do |user|
                { 'id' => user.id, 'name' => user.name, 'type' => 'user' }
              end
            }
          end

          it 'calls the user_mentions_proc and returns the result' do
            expect(Commontator.user_mentions_proc).to(
              receive(:call).with(@user, @thread, search_phrase).and_return(valid_result)
            )

            call_request
            expect(response).to have_http_status(:success)

            response_body = JSON.parse(response.body)
            expect(response_body['errors']).to be_nil
            expect(response_body).to eq valid_response
          end
        end
      end

      context 'mentions disabled' do
        before(:all) { Commontator.mentions_enabled = false }
        after(:all)  { Commontator.mentions_enabled = true }

        it 'returns 403 Forbidden' do
          call_request
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  context 'unauthorized' do
    context 'GET #show' do
      it 'returns 403 Forbidden' do
        get :show, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)

        controller.current_user = @user
        get :show, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'PUT #close' do
      it 'returns 403 Forbidden' do
        put :close, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq false

        controller.current_user = @user
        put :close, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq false

        @user.can_read = true
        put :close, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq false

        @user.can_edit = true
        expect(@thread.close).to eq true
        put :close, params: { id: @thread.id }
        expect(response).to redirect_to(@thread)
        expect(assigns(:thread).errors).not_to be_empty
      end
    end

    context 'PUT #reopen' do
      it 'returns 403 Forbidden' do
        expect(@thread.close).to eq true
        put :reopen, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq true

        controller.current_user = @user
        put :reopen, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq true

        @user.can_read = true
        put :reopen, params: { id: @thread.id }
        expect(response).to have_http_status(:forbidden)
        @thread.reload
        expect(@thread.is_closed?).to eq true

        expect(@thread.reopen).to eq true
        @user.can_edit = true
        put :reopen, params: { id: @thread.id }
        expect(response).to redirect_to(@thread)
        expect(assigns(:thread).errors).not_to be_empty
      end
    end

    context 'GET #mentions' do
      it 'returns 403 Forbidden' do
        get :mentions, params: { id: @thread.id, format: :json, q: 'User' }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
