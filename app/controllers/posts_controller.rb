class PostsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    else
      redirect_to root_path, alert: "Post could not be created."
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@post) }
      format.html { redirect_back fallback_location: root_path, notice: "Post deleted." }
    end
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end
