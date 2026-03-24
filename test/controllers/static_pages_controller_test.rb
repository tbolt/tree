require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home for unauthenticated user" do
    get root_path
    assert_response :success
    assert_select "h1", "The Social Network that doesn't track you."
  end

  test "should show feed for authenticated user" do
    sign_in users(:confirmed_user)
    get root_path
    assert_response :success
    assert_select "h1", "Feed"
  end
end
