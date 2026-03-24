require "test_helper"

class FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed_user)
    @other_user = users(:unconfirmed_user)
  end

  test "should require auth to follow" do
    post follows_path, params: { followed_id: @other_user.id }
    assert_redirected_to login_path
  end

  test "should create follow" do
    sign_in @user
    @user.unfollow(@other_user) # ensure clean state
    assert_difference "Follow.count", 1 do
      post follows_path, params: { followed_id: @other_user.id }
    end
    assert_redirected_to profile_path(@other_user.username)
  end

  test "should destroy follow" do
    sign_in @user
    follow = @user.sent_follows.find_by(followed: @other_user)
    assert_difference "Follow.count", -1 do
      delete follow_path(follow)
    end
    assert_redirected_to profile_path(@other_user.username)
  end

  test "should get followers page" do
    get followers_path(@user.username)
    assert_response :success
  end

  test "should get following page" do
    get following_path(@user.username)
    assert_response :success
  end
end
