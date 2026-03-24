require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @user = users(:confirmed_user)
    @other_user = users(:unconfirmed_user)
  end

  test "should be valid with valid attributes" do
    # Clear existing follow fixture first
    Follow.delete_all
    follow = Follow.new(follower: @user, followed: @other_user)
    assert follow.valid?
  end

  test "should enforce uniqueness of follower and followed pair" do
    # Fixture already has confirmed_user following unconfirmed_user
    duplicate = Follow.new(follower: @user, followed: @other_user)
    assert_not duplicate.valid?
  end

  test "should prevent self-follow" do
    follow = Follow.new(follower: @user, followed: @user)
    assert_not follow.valid?
  end

  test "should cascade delete when user is destroyed" do
    assert_difference "Follow.count", -1 do
      @other_user.destroy
    end
  end
end
