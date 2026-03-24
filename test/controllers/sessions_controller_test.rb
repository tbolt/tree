require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed_user)
  end

  test "should get login page" do
    get login_path
    assert_response :success
  end

  test "should sign in with valid credentials" do
    post login_path, params: { user: { email: @user.email, password: "password" } }
    assert_redirected_to root_path
    follow_redirect!
    assert_select "h1", "Feed"
  end

  test "should not sign in with invalid credentials" do
    post login_path, params: { user: { email: @user.email, password: "wrong" } }
    assert_response :unprocessable_entity
  end

  test "should sign out" do
    sign_in @user
    delete logout_path
    assert_redirected_to root_path
  end
end
