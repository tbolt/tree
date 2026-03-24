class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @post = Post.new
      @posts = current_user.feed
      @posts = @posts.where("posts.created_at < ?", params[:before]) if params[:before].present?
      @posts = @posts.limit(20)
      @next_cursor = @posts.last&.created_at
    end
  end
end
