# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  setup do
    @comment = FactoryGirl.create(:comment)
    @question = @comment.comment_thread.commentable
    @user = @comment.creator
    FactoryGirl.create(:project_question, :question => @question, :project => Project.default_for_user!(@user))
    @published_question = make_simple_question(:method => :create, :published => true)
    @published_comment = FactoryGirl.create(:comment,
                                        :comment_thread => @published_question.comment_thread)
  end

  test "should not get index not logged in" do
    get :index, :question_id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get index not authorized" do
    user_login
    get :index, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get index" do
    sign_in @user
    get :index, :question_id => @question.to_param
    assert_response :success
  end

  test "should get index published question" do
    user_login
    get :index, :question_id => @published_question.to_param
    assert_response :success
  end

  test "should not get new not logged in" do
    get :new, :question_id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get new not authorized" do
    user_login
    get :new, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get new" do
    sign_in @user
    get :new, :question_id => @question.to_param
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should get new published question" do
    user_login
    get :new, :question_id => @published_question.to_param
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should not create comment not logged in" do
    assert_difference('Comment.count', 0) do
      post :create, :question_id => @question.to_param, :comment => @comment.attributes
    end

    assert_redirected_to login_path
  end

  test "should not create comment not authorized" do
    user_login
    assert_difference('Comment.count', 0) do
      post :create, :question_id => @question.to_param, :comment => @comment.attributes
    end

    assert_response(403)
  end

  test "should create comment" do
    sign_in @user
    assert_difference('Comment.count') do
      post :create, :question_id => @question.to_param, :comment => @comment.attributes
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should create comment published question" do
    user_login
    assert_difference('Comment.count') do
      post :create, :question_id => @published_question.to_param, :comment => @comment.attributes
    end

    assert_redirected_to question_comments_path(@published_question.to_param)
  end

  test "should not show comment not logged in" do
    get :show, :id => @comment.to_param
    assert_redirected_to login_path
  end

  test "should not show comment not authorized" do
    user_login
    get :show, :id => @comment.to_param
    assert_response(403)
  end

  test "should show comment" do
    sign_in @user
    get :show, :id => @comment.to_param
    assert_response :success
  end

  test "should show comment published question" do
    user_login
    get :show, :id => @published_comment.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @comment.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not authorized" do
    user_login
    get :edit, :id => @comment.to_param
    assert_response(403)
  end

  test "should get edit" do
    sign_in @user
    get :edit, :id => @comment.to_param
    assert_response :success
  end

  test "should not update comment not logged in" do
    put :update, :id => @comment.to_param
    assert_redirected_to login_path
  end

  test "should not update comment not authorized" do
    user_login
    put :update, :id => @comment.to_param
    assert_response(403)
  end

  test "should update comment" do
    sign_in @user
    put :update, :id => @comment.to_param
    assert_redirected_to question_comments_path(@question.to_param)
  end

  test "should not destroy comment not logged in" do
    assert_difference('Comment.count', 0) do
      delete :destroy, :id => @comment.to_param
    end

    assert_redirected_to login_path
  end

  test "should not destroy comment not authorized" do
    user_login
    assert_difference('Comment.count', 0) do
      delete :destroy, :id => @comment.to_param
    end

    assert_response(403)
  end

  test "should destroy comment" do
    sign_in @user
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => @comment.to_param
    end

    assert_redirected_to question_comments_path(@question.to_param)
  end

end
