require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:confirmed_user)
    @other_user = users(:unconfirmed_user)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require username" do
    @user.username = nil
    assert_not @user.valid?
  end

  test "should enforce unique email" do
    duplicate = @user.dup
    assert_not duplicate.valid?
  end

  test "should enforce unique username" do
    duplicate = @user.dup
    duplicate.email = "different@example.com"
    assert_not duplicate.valid?
  end

  test "should validate display_name max length" do
    @user.display_name = "a" * 51
    assert_not @user.valid?
    @user.display_name = "a" * 50
    assert @user.valid?
  end

  test "should validate bio max length" do
    @user.bio = "a" * 161
    assert_not @user.valid?
    @user.bio = "a" * 160
    assert @user.valid?
  end

  test "display_name_or_username returns display_name when present" do
    @user.display_name = "My Name"
    assert_equal "My Name", @user.display_name_or_username
  end

  test "display_name_or_username returns username when display_name blank" do
    @user.display_name = nil
    assert_equal @user.username, @user.display_name_or_username
    @user.display_name = ""
    assert_equal @user.username, @user.display_name_or_username
  end

  test "can follow another user" do
    @user.unfollow(@other_user) # ensure clean state
    assert_not @user.following?(@other_user)
    @user.follow(@other_user)
    assert @user.following?(@other_user)
    assert_includes @other_user.followers, @user
  end

  test "can unfollow a user" do
    @user.follow(@other_user)
    @user.unfollow(@other_user)
    assert_not @user.following?(@other_user)
  end

  test "cannot follow self" do
    @user.follow(@user)
    assert_not @user.following?(@user)
  end

  test "feed returns posts from followed users only" do
    @user.follow(@other_user)
    other_post = posts(:recent_post) # belongs to unconfirmed_user
    own_post = posts(:hello_post) # belongs to confirmed_user

    feed = @user.feed
    assert_includes feed, other_post
    assert_not_includes feed, own_post
  end

  test "confirmed? returns true when confirmed_at present" do
    assert @user.confirmed?
    assert_not @other_user.confirmed?
  end
end
