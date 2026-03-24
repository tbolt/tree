require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed_user)
  end

  test "should require auth to create post" do
    post posts_path, params: { post: { body: "Hello" } }
    assert_redirected_to login_path
  end

  test "should create post" do
    sign_in @user
    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { body: "A new post!" } }
    end
    assert_redirected_to root_path
  end

  test "should not create post with blank body" do
    sign_in @user
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { body: "" } }
    end
  end

  test "should delete own post" do
    sign_in @user
    user_post = posts(:hello_post)
    assert_difference "Post.count", -1 do
      delete post_path(user_post)
    end
  end

  test "should not delete another users post" do
    sign_in @user
    other_post = posts(:recent_post)
    assert_raises ActiveRecord::RecordNotFound do
      delete post_path(other_post)
    end
  end
end
