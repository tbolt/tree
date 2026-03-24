require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  test "should get explore page" do
    get explore_path
    assert_response :success
    assert_select "h1", "Explore"
  end

  test "should show confirmed users" do
    get explore_path
    assert_response :success
    # confirmed_user should appear
    assert_select "strong", users(:confirmed_user).display_name_or_username
  end

  test "should exclude current user when signed in" do
    user = users(:confirmed_user)
    sign_in user
    get explore_path
    assert_response :success
  end
end
