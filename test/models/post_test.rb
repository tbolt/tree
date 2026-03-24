require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @user = users(:confirmed_user)
  end

  test "should be valid with valid attributes" do
    post = Post.new(user: @user, body: "Hello world")
    assert post.valid?
  end

  test "should require body" do
    post = Post.new(user: @user, body: nil)
    assert_not post.valid?
    post.body = ""
    assert_not post.valid?
  end

  test "should enforce body max length of 500" do
    post = Post.new(user: @user, body: "a" * 501)
    assert_not post.valid?
    post.body = "a" * 500
    assert post.valid?
  end

  test "recent scope orders by created_at desc" do
    old_post = @user.posts.create!(body: "Old", created_at: 2.hours.ago)
    new_post = @user.posts.create!(body: "New", created_at: 1.minute.ago)
    results = Post.recent
    assert results.index(new_post) < results.index(old_post)
  end

  test "should belong to user" do
    post = Post.new(body: "No user")
    assert_not post.valid?
  end
end
