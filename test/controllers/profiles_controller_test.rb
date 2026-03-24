require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed_user)
  end

  test "should require auth for edit profile" do
    get edit_profile_path
    assert_redirected_to login_path
  end

  test "should get edit profile when signed in" do
    sign_in @user
    get edit_profile_path
    assert_response :success
  end

  test "should update profile" do
    sign_in @user
    patch update_profile_path, params: { user: { display_name: "New Name", bio: "New bio" } }
    assert_redirected_to profile_path(@user.username)
    @user.reload
    assert_equal "New Name", @user.display_name
    assert_equal "New bio", @user.bio
  end

  test "should reject too-long display_name" do
    sign_in @user
    patch update_profile_path, params: { user: { display_name: "a" * 51 } }
    assert_response :unprocessable_entity
  end
end
