class TweetsController < ApplicationController
    before_action :move_to_index, except: :index

    def index
      @tweets = Tweet.includes(:user).page(params[:page]).per(5).order("created_at DESC")
    end

    def new
    end

    def create
      tweet = Tweet.new(image: tweet_params[:image], text: tweet_params[:text], user_id: current_user.id)
      if tweet.save
        flash[:notice] = "メッセージ送信成功"
      else
        flash.now[:alert] = "メッセージ送信失敗"
        render "new"
      end
    end

    def destroy
      tweet = Tweet.find(params[:id])
      if tweet.user_id == current_user.id
        tweet.destroy
      end
    end

    def edit
      @tweet = Tweet.find(params[:id])
    end

    def update
      tweet = Tweet.find(params[:id])
      if tweet.user_id == current_user.id
        tweet.update(tweet_params)
      else
        flash[:alert] = "他のユーザーの投稿の編集はできません"
        redirect_to action: :index
      end
    end

    def show
     @tweet = Tweet.find(params[:id])
     @comments = @tweet.comments.includes(:user)
    end

    private
    def tweet_params
      params.permit(:image, :text)
    end

    def move_to_index
      redirect_to action: :index unless user_signed_in?
    end
end
