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
      Thread.current[:user] = @user
    end

    context 'GET #new' do
      context 'unnested comments' do
        let(:params) { { thread_id: @thread.id } }

        it 'initializes a new comment for the new comment form' do
          get :new, params: params
          expect(response).to redirect_to(@commontable_path)
          expect(assigns(:comment).errors).to be_empty
          expect(assigns(:comment).parent).to be_nil
          expect(assigns(:comment).body).to be_nil

          @user.can_read = false
          @user.can_edit = true
          get :new, params: params
          expect(response).to redirect_to(@commontable_path)
          expect(assigns(:comment).errors).to be_empty
          expect(assigns(:comment).parent).to be_nil
          expect(assigns(:comment).body).to be_nil

          @user.can_edit = false
          @user.is_admin = true
          get :new, params: params
          expect(response).to redirect_to(@commontable_path)
          expect(assigns(:comment).errors).to be_empty
          expect(assigns(:comment).parent).to be_nil
          expect(assigns(:comment).body).to be_nil
        end
      end

      context 'nested comments' do
        let(:params) { { thread_id: @thread.id, comment: { parent_id: @comment.id } } }

        [ :n, :q, :i, :b ].each do |comment_reply_style|
          context "comment_reply_style #{comment_reply_style}" do
            before do
              expect_any_instance_of(Commontator::CommontableConfig).to(
                receive(:comment_reply_style).exactly(3).times.and_return(comment_reply_style)
              )
            end

            it "initializes a new comment and sets its parent#{
              ' and body' if [ :q, :b ].include? comment_reply_style
            }" do
              get :new, params: params
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).parent).to eq @comment
              if [ :q, :b ].include? comment_reply_style
                expect(assigns(:comment).body).to eq "<blockquote><span class=\"author\">#{
                  Commontator.commontator_name(@comment.creator)
                }</span>\n#{@comment.body}\n</blockquote>\n"
              else
                expect(assigns(:comment).body).to be_nil
              end

              @user.can_read = false
              @user.can_edit = true
              get :new, params: params
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).parent).to eq @comment
              if [ :q, :b ].include? comment_reply_style
                expect(assigns(:comment).body).to eq "<blockquote><span class=\"author\">#{
                  Commontator.commontator_name(@comment.creator)
                }</span>\n#{@comment.body}\n</blockquote>\n"
              else
                expect(assigns(:comment).body).to be_nil
              end

              @user.can_edit = false
              @user.is_admin = true
              get :new, params: params
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).parent).to eq @comment
              if [ :q, :b ].include? comment_reply_style
                expect(assigns(:comment).body).to eq "<blockquote><span class=\"author\">#{
                  Commontator.commontator_name(@comment.creator)
                }</span>\n#{@comment.body}\n</blockquote>\n"
              else
                expect(assigns(:comment).body).to be_nil
              end
            end
          end
        end
      end
    end

    context 'POST #create' do
      context 'thread open' do
        context 'not double posting' do
          context 'unnested comment' do
            let(:params) { ->(body) { { thread_id: @thread.id, comment: { body: body } } } }

            it 'creates a new comment' do
              body = 'Something else'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to be_nil

              @user.can_read = false
              @user.can_edit = true
              body = 'Another thing'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to be_nil

              @user.can_edit = false
              @user.is_admin = true
              body = 'And this too'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to be_nil
            end
          end

          context 'nested comment' do
            let(:params) do
              ->(body) do
                { thread_id: @thread.id, comment: { parent_id: @comment.id, body: body } }
              end
            end

            it 'creates a new comment and sets its parent' do
              body = 'Something else'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to eq @comment

              @user.can_read = false
              @user.can_edit = true
              body = 'Another thing'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to eq @comment

              @user.can_edit = false
              @user.is_admin = true
              body = 'And this too'
              post :create, params: params.call(body)
              expect(response).to redirect_to(@commontable_path)
              expect(assigns(:comment).errors).to be_empty
              expect(assigns(:comment).body).to eq body
              expect(assigns(:comment).creator).to eq @user
              expect(assigns(:comment).editor).to be_nil
              expect(assigns(:comment).thread).to eq @thread
              expect(assigns(:comment).parent).to eq @comment
            end
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

            context 'mentions enabled' do
              it 'subscribes mentioned users' do
                expect(@thread.subscription_for(user_to_subscribe)).to be_nil
                call_request
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

            context 'mentions disabled' do
              before { @thread.config.mentions_enabled = false }
              after  { @thread.config.mentions_enabled = true }

              it 'does not subscribe mentioned or unmentioned users' do
                call_request
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
            expect(response).to redirect_to(@commontable_path)
            expect(assigns(:comment).errors).not_to be_empty

            post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
            expect(response).to redirect_to(@commontable_path)
            expect(assigns(:comment).errors).to be_empty
            expect(assigns(:comment).body).to eq 'Something else'
            expect(assigns(:comment).creator).to eq @user
            expect(assigns(:comment).editor).to be_nil
            expect(assigns(:comment).thread).to eq @thread

            post :create, params: { thread_id: @thread.id, comment: { body: 'Something else' } }
            expect(response).to redirect_to(@commontable_path)
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
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty

        @user.can_read = false
        @user.can_edit = true
        get :edit, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty

        @user.can_edit = false
        @user.is_admin = true
        get :edit, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
      end
    end

    context 'PUT #update' do
      it 'works' do
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user

        @user.can_read = false
        @user.can_edit = true
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user

        @user.can_edit = false
        @user.is_admin = true
        put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).editor).to eq @user
      end
    end

    context 'DELETE #destroy' do
      it 'works if not deleted' do
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq @user

        user2 = DummyUser.create
        Thread.current[:user] = user2
        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.save!

        expect(assigns(:comment).undelete_by(@user)).to eq true
        user2.can_edit = true
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq user2

        expect(assigns(:comment).undelete_by(@user)).to eq true
        user2.can_edit = false
        user2.is_admin = true
        put :delete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq true
        expect(assigns(:comment).editor).to eq user2
      end
    end

    context 'PUT #undelete' do
      it 'works if deleted' do
        expect(@comment.delete_by(@user)).to eq true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false

        user2 = DummyUser.create
        Thread.current[:user] = user2
        comment2 = Commontator::Comment.new
        comment2.thread = @thread
        comment2.creator = @user
        comment2.body = 'Something else'
        comment2.save!

        expect(assigns(:comment).delete_by(@user)).to eq true
        user2.can_edit = true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false

        expect(assigns(:comment).delete_by(@user)).to eq true
        user2.can_edit = false
        user2.is_admin = true
        put :undelete, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).errors).to be_empty
        expect(assigns(:comment).is_deleted?).to eq false
      end
    end

    context 'PUT #upvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        Thread.current[:user] = user2

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty

        expect(@comment.downvote_from(user2)).to eq true

        put :upvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes.count).to eq 1
        expect(assigns(:comment).get_downvotes).to be_empty
      end
    end

    context 'PUT #downvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        Thread.current[:user] = user2

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1

        expect(@comment.upvote_from(user2)).to eq true

        put :downvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(@comment.get_upvotes).to be_empty
        expect(@comment.get_downvotes.count).to eq 1
      end
    end

    context 'PUT #unvote' do
      it 'works' do
        user2 = DummyUser.create
        user2.can_read = true
        Thread.current[:user] = user2

        expect(@comment.upvote_from(user2)).to eq true
        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty

        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty

        expect(@comment.downvote_from(user2)).to eq true
        put :unvote, params: { id: @comment.id }
        expect(response).to redirect_to(@commontable_path)
        expect(assigns(:comment).get_upvotes).to be_empty
        expect(assigns(:comment).get_downvotes).to be_empty
      end
    end
  end

  { anonymous: nil, unauthorized: @user }.each do |ctx, user|
    context ctx.to_s do
      before { Thread.current[:user] = user }

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

          Thread.current[:user] = @user
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)

          user2 = DummyUser.create
          user2.can_read = true
          user2.can_edit = true
          user2.is_admin = true
          Thread.current[:user] = user2
          get :edit, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)

          @user.can_read = true
          @user.can_edit = true
          @user.is_admin = true
          Thread.current[:user] = @user
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

          Thread.current[:user] = @user
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil

          user2 = DummyUser.create
          user2.can_read = true
          user2.can_edit = true
          user2.is_admin = true
          Thread.current[:user] = user2
          put :update, params: { id: @comment.id, comment: { body: 'Something else' } }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.body).to eq 'Something'
          expect(@comment.editor).to be_nil

          @user.can_read = true
          @user.can_edit = true
          @user.is_admin = true
          Thread.current[:user] = @user
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

          Thread.current[:user] = @user

          put :delete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq false

          @user.can_read = true
          expect(@comment.delete_by(@user)).to eq true
          put :delete, params: { id: @comment.id }
          expect(response).to redirect_to(@commontable_path)
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

          Thread.current[:user] = @user

          put :undelete, params: { id: @comment.id }
          expect(response).to have_http_status(:forbidden)
          @comment.reload
          expect(@comment.is_deleted?).to eq true

          @user.can_read = true
          expect(@comment.undelete_by(@user)).to eq true
          put :undelete, params: { id: @comment.id }
          expect(response).to redirect_to(@commontable_path)
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

        Thread.current[:user] = user
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
