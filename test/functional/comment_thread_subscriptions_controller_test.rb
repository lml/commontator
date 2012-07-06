require 'test_helper'

class CommentThreadSubscriptionsControllerTest < ActionController::TestCase

  setup do
    @question = FactoryGirl.create(:simple_question)
    @user = FactoryGirl.create(:user)
    FactoryGirl.create(:project_question, :question => @question, :project => Project.default_for_user!(@user))
    @published_question = make_simple_question(:method => :create, :published => true)
    @user2 = FactoryGirl.create(:user)
  end

  test "should not get index not logged in" do
    get :index
    assert_redirected_to login_path
  end

  test "should get index" do
    user_login
    get :index
    assert_response :success
  end

  test "should not create comment_thread_subscription not logged in" do
    assert_difference('CommentThreadSubscription.count', 0) do
      get :create, :question_id => @question.to_param
    end

    assert_redirected_to login_path
  end

  test "should not create comment_thread_subscription not authorized" do
    user_login
    assert_difference('CommentThreadSubscription.count', 0) do
      get :create, :question_id => @question.to_param
    end

    assert_response(403)
  end

  test "should not create comment_thread_subscription already subscribed" do
    sign_in @user
    FactoryGirl.create(:comment_thread_subscription,
                   :user => @user, :comment_thread => @question.comment_thread)
    assert_difference('CommentThreadSubscription.count', 0) do
      get :create, :question_id => @question.to_param
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should create comment_thread_subscription" do
    sign_in @user
    assert_difference('CommentThreadSubscription.count') do
      get :create, :question_id => @question.to_param
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should create comment_thread_subscription published question" do
    user_login
    assert_difference('CommentThreadSubscription.count') do
      get :create, :question_id => @published_question.to_param
    end

    assert_redirected_to question_comments_path(@published_question.to_param)
  end

  test "should not destroy comment_thread_subscription not logged in" do
    FactoryGirl.create(:comment_thread_subscription,
                   :user => @user, :comment_thread => @question.comment_thread)
    assert_difference('CommentThreadSubscription.count', 0) do
      get :destroy, :question_id => @question.to_param
    end

    assert_redirected_to login_path
  end

  test "should not destroy comment_thread_subscription not authorized" do
    user_login
    FactoryGirl.create(:comment_thread_subscription,
                   :user => @user, :comment_thread => @question.comment_thread)
    assert_difference('CommentThreadSubscription.count', 0) do
      get :destroy, :question_id => @question.to_param
    end

    assert_response(403)
  end

  test "should not destroy comment_thread_subscription no subscription" do
    sign_in @user
    assert_difference('CommentThreadSubscription.count', 0) do
      get :destroy, :question_id => @question.to_param
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should destroy comment_thread_subscription" do
    sign_in @user
    FactoryGirl.create(:comment_thread_subscription,
                   :user => @user, :comment_thread => @question.comment_thread)
    assert_difference('CommentThreadSubscription.count', -1) do
      get :destroy, :question_id => @question.to_param
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should destroy comment_thread_subscription published question" do
    sign_in @user2
    FactoryGirl.create(:comment_thread_subscription,
                   :user => @user2, :comment_thread => @published_question.comment_thread)
    assert_difference('CommentThreadSubscription.count', -1) do
      get :destroy, :question_id => @published_question.to_param
    end

    assert_redirected_to question_comments_path(@published_question.to_param)
  end

end
