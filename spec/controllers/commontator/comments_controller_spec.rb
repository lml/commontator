require 'rails_helper'
require 'acts_as_votable'

RSpec.describe Commontator::CommentsController, type: :controller do
  routes { Commontator::Engine.routes }

  before do
    setup_controller_spec

    @comment = Commontator::Comment.new
    @comment.thread = @thread
    @comment.creator = @user
    @comment.body = 'Something'
    @comment.save!
  end

  context 'authorized' do
    before do
      @user.can_read = true
      controller.current_user = @user
    end

    context 'GET #new' do
      it 'works' do
        get :new, params: { thread_id: @thread.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty

        @user.can_read = false
        @user.can_edit = true
        get :new, params: { thread_id: @thread.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty

        @user.can_edit = false
        @user.is_admin = true
        get :new, params: { thread_id: @thread.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
      end
    end

    context 'POST #create' do
      context 'thread open' do
        context 'not double posting' do
          it 'works' do
            post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
            expect(response).to redirect_to @thread
            expect(assigns(:comment).errors).to be_empty
            expect(assigns(:comment).body).to eq 'Something else'
            expect(assigns(:comment).creator).to eq @user
            expect(assigns(:comment).editor).to be_nil
            expect(assigns(:comment).thread).to eq @thread

            @user.can_read = false
            @user.can_edit = true
            post :create, params: { thread_id: @thread.id, comment: { body: 'Another thing' } }
            expect(response).to redirect_to @thread
            expect(assigns(:comment).errors).to be_empty
            expect(assigns(:comment).body).to eq 'Another thing'
            expect(assigns(:comment).creator).to eq @user
            expect(assigns(:comment).editor).to be_nil
            expect(assigns(:comment).thread).to eq @thread

            @user.can_edit = false
            @user.is_admin = true
            post :create, params: { thread_id: @thread.id, comment: { body: 'And this too' } }
            expect(response).to redirect_to @thread
            expect(assigns(:comment).errors).to be_empty
            expect(assigns(:comment).body).to eq 'And this too'
            expect(assigns(:comment).creator).to eq @user
            expect(assigns(:comment).editor).to be_nil
            expect(assigns(:comment).thread).to eq @thread
          end

          context 'without subscribers' do
            it 'does not send subscription emails' do
              user2 = DummyUser.create
              user2.can_read = true

              expect_any_instance_of(ActionMailer::MessageDelivery).not_to receive(:deliver_later)
              post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
              expect(assigns(:comment).errors).to be_empty
            end
          end

          context 'with subscribers' do
            it 'sends subscription emails' do
              user2 = DummyUser.create
              user2.can_read = true
              @thread.subscribe(user2)

              expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
              post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
              expect(assigns(:comment).errors).to be_empty
            end
          end

          context 'with another user mentioned' do
            let!(:user_to_subscribe) { DummyUser.create }
            let!(:other_user)        { DummyUser.create }

            let(:attributes)         { { body: 'Some comment' } }
            let(:call_request)       do
              post :create, params: {
                thread_id: @thread.id, comment: attributes, mentioned_ids: [user_to_subscribe.id]
              }
            end

            context 'mentions are enabled' do
              it 'subscribes the mentioned user' do
                expect { call_request }.to change { Commontator::Subscription.count }.by(1)
                expect(@thread.subscription_for(user_to_subscribe)).to be_present
              end

              it 'does not subscribe unmentioned users' do
                call_request
                expect(@thread.subscription_for(other_user)).to be_nil
              end

              it 'sends a subscription email' do
                expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
                call_request
              end
            end

            context 'mentions are disabled' do
              before { @thread.config.mentions_enabled = false }
              after  { @thread.config.mentions_enabled = true }

              it 'does not subscribe any users' do
                expect{ call_request }.not_to change { Commontator::Subscription.count }
                expect(@thread.subscription_for(user_to_subscribe)).to be_nil
                expect(@thread.subscription_for(other_user)).to be_nil
              end

              it 'does not send subscription emails' do
                expect_any_instance_of(ActionMailer::MessageDelivery).not_to receive(:deliver_later)
                call_request
              end
            end
          end
        end

        context 'double posting' do
          it 'redirects to the thread and returns an error message' do
            post :create, params: { thread_id: @thread.id, comment: { body: 'Something' } }
            assert_redirected_to @thread
            expect(assigns(:comment).errors).not_to be_empty

            post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
            expect(response).to redirect_to @thread
            expect(assigns(:comment).errors).to be_empty
            expect(assigns(:comment).body).to eq 'Something else'
            expect(assigns(:comment).creator).to eq @user
            expect(assigns(:comment).editor).to be_nil
            expect(assigns(:comment).thread).to eq @thread

            post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
            expect(response).to redirect_to @thread
            expect(assigns(:comment).errors).not_to be_empty
          end
        end
      end

      context 'thread closed' do
        before { expect(@thread.close).to eq true }

        it 'returns 403 Forbidden' do
          @user.can_edit = true
          @user.is_admin = true
          post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'GET #edit' do
      it 'works' do
        get :edit, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty

        @user.can_read = false
        @user.can_edit = true
        get :edit, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty

        @user.can_edit = false
        @user.is_admin = true
        get :edit, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
      end
    end

    context 'PUT #update' do
      it 'works' do
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user

        @user.can_read = false
        @user.can_edit = true
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user

        @user.can_edit = false
        @user.is_admin = true
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user
      end
    end

    context 'DELETE #destroy' do
      it 'works if not deleted' do
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq @user

        user2 = DummyUser.create
        controller.current_user = user2
        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.save!

        expect(assigns(:comment).undelete_by(@user)).to eq true
        user2.can_edit = true
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq user2

        expect(assigns(:comment).undelete_by(@user)).to eq true
        user2.can_edit = false
        user2.is_admin = true
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq user2
      end
    end

    context 'PUT #undelete' do
      it 'works if deleted' do
        expect(@comment.delete_by(@user)).to eq true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false

        user2 = DummyUser.create
        controller.current_user = user2
        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.save!

        expect(assigns(:comment).delete_by(@user)).to eq true
        user2.can_edit = true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false

        expect(assigns(:comment).delete_by(@user)).to eq true
        user2.can_edit = false
        user2.is_admin = true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false
      end
    end

    context 'PUT #upvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        controller.current_user = user2

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty

        expect(@comment.downvote_from(user2)).to eq true

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty
      end
    end

    context 'PUT #downvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        controller.current_user = user2

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1

        expect(@comment.upvote_from(user2)).to eq true

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1
      end
    end

    context 'PUT #unvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        controller.current_user = user2

        expect(@comment.upvote_from(user2)).to eq true
        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty

        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty

        expect(@comment.downvote_from(user2)).to eq true
        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to @thread
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty
      end
    end
  end

  { anonymous: nil, unauthorized: @user }.each do |ctx, user|
    context ctx.to_s do
      before { controller.current_user = user }

      context 'GET #new' do
        it 'returns 403 Forbidden' do
          get :new, params: { thread_id: @thread.id }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'POST #create' do
        it 'returns 403 Forbidden' do
          post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'GET #edit' do
        it 'returns 403 Forbidden' do
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)

          controller.current_user = @user
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)

          user2 = DummyUser.create
          user2.can_read = true
          user2.can_edit = true
          user2.is_admin = true
          controller.current_user = user2
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)

          @user.can_read = true
          @user.can_edit = true
          @user.is_admin = true
          controller.current_user = @user
          comment2 = Commontator::Comment.new
          comment2.thread = @thread
          comment2.creator = @user
          comment2.body = 'Something else'
          comment2.save!
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'PUT #update' do
        it 'returns 403 Forbidden' do
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil

          controller.current_user = @user
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil

          user2 = DummyUser.create
          user2.can_read = true
          user2.can_edit = true
          user2.is_admin = true
          controller.current_user = user2
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil

          @user.can_read = true
          @user.can_edit = true
          @user.is_admin = true
          controller.current_user = @user
          comment2 = Commontator::Comment.new
          comment2.thread = @thread
          comment2.creator = @user
          comment2.body = 'Something else'
          comment2.save!
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil
        end
      end

      context 'DELETE #destroy' do
        it 'returns 403 Forbidden' do
          put :delete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq false

          controller.current_user = @user

          put :delete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq false

          @user.can_read = true
          expect(@comment.delete_by(@user)).to eq true
          put :delete, params: { id: @comment.id }
          expect(response).to redirect_to @thread
          expect(assigns(:comment).errors).not_to be_empty

          comment2 = Commontator::Comment.new
          comment2.thread = @thread
          comment2.creator = @user
          comment2.body = 'Something else'
          comment2.save!
          expect(@comment.undelete_by(@user)).to eq true
          put :delete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq false
        end
      end

      context 'PUT #undelete' do
        it 'returns 403 Forbidden' do
          expect(@comment.delete_by(@user)).to eq true
          put :undelete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq true

          controller.current_user = @user

          put :undelete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq true

          @user.can_read = true
          expect(@comment.undelete_by(@user)).to eq true
          put :undelete, params: { id: @comment.id }
          expect(response).to redirect_to @thread
          expect(assigns(:comment).errors).not_to be_empty

          user2 = DummyUser.create
          user2.can_read = true
          user2.can_edit = true
          user2.is_admin = true
          expect(@comment.delete_by(user2)).to eq true
          put :undelete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq true

          comment2 = Commontator::Comment.new
          comment2.thread = @thread
          comment2.creator = @user
          comment2.body = 'Something else'
          comment2.save!
          expect(@comment.undelete_by(@user)).to eq true
          expect(@comment.delete_by(@user)).to eq true
          put :undelete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq true
        end
      end
    end
  end

  { anonymous: nil, :'same user' => @user, unauthorized: DummyUser.create }.each do |ctx, user|
    context ctx.to_s do
      before do
        expect(Commontator::Comment.is_votable?).to eq true

        @user.can_read = true

        controller.current_user = user
      end

      context 'PUT #upvote' do
        it 'returns 403 Forbidden' do
          put :upvote, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.get_upvotes).to be_empty
          expect(@comment.get_downvotes).to be_empty
        end
      end

      context 'PUT #downvote' do
        it 'returns 403 Forbidden' do
          put :downvote, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.get_upvotes).to be_empty
          expect(@comment.get_downvotes).to be_empty
        end
      end

      context 'PUT #unvote' do
        it 'returns 403 Forbidden' do
          expect(@comment.upvote_from(@user)).to eq true

          put :unvote, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.get_upvotes.count).to eq 1
          expect(@comment.get_downvotes).to be_empty
        end
      end
    end
  end
end
