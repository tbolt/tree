class FollowsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to profile_path(@user.username) }
    end
  end

  def destroy
    follow = current_user.sent_follows.find(params[:id])
    @user = follow.followed
    follow.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to profile_path(@user.username) }
    end
  end

  def followers
    @user = User.find_by!(username: params[:username])
    @users = @user.followers.order("follows.created_at DESC")
    @users = @users.where("follows.created_at < ?", params[:before]) if params[:before].present?
    @users = @users.limit(20)
    @next_cursor = @users.last ? Follow.find_by(followed: @user, follower: @users.last)&.created_at : nil
  end

  def following
    @user = User.find_by!(username: params[:username])
    @users = @user.following.order("follows.created_at DESC")
    @users = @users.where("follows.created_at < ?", params[:before]) if params[:before].present?
    @users = @users.limit(20)
    @next_cursor = @users.last ? Follow.find_by(follower: @user, followed: @users.last)&.created_at : nil
  end
end
