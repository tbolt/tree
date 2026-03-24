require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed_user)
  end

  test "should get sign up page" do
    get sign_up_path
    assert_response :success
  end

  test "should create user" do
    assert_difference "User.count", 1 do
      post sign_up_path, params: { user: {
        email: "new@example.com",
        username: "newuser",
        password: "password",
        password_confirmation: "password"
      } }
    end
    assert_redirected_to root_path
  end

  test "should show user profile" do
    get profile_path(@user.username)
    assert_response :success
    assert_select "h1", @user.display_name_or_username
  end

  test "should require auth for account page" do
    get account_path
    assert_redirected_to login_path
  end

  test "should get account page when signed in" do
    sign_in @user
    get account_path
    assert_response :success
  end

  test "should update account with correct password" do
    sign_in @user
    put account_path, params: { user: {
      current_password: "password",
      password: "newpassword",
      password_confirmation: "newpassword"
    } }
    assert_redirected_to root_path
  end
end
