class ExploreController < ApplicationController
  def index
    @users = User.where.not(confirmed_at: nil)
    @users = @users.where.not(id: current_user.id) if user_signed_in?
    @users = @users.order(created_at: :desc, id: :desc)
    @users = @users.where("created_at < ?", params[:before]) if params[:before].present?
    @users = @users.limit(20)
    @next_cursor = @users.last&.created_at
  end
end
