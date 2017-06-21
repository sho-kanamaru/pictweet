require 'rails_helper'

describe TweetsController, type: :controller do

  let(:user) { create(:user) }

  describe 'GET #index' do

    context 'with logged in user' do
      before do
        login_user user
        get :index
      end

      it "populates an array of tweets ordered by created_at DESC" do
        tweets = create_list(:tweet, 3)
        expect(assigns(:tweets)).to match(tweets.sort{ |a, b| b.created_at <=> a.created_at } )
      end

      it "renders the :index template" do
        expect(response).to render_template :index
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        get :index
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET #new' do

    context 'with logged in user' do
      before do
        login_user user
        get :new
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        get :new
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST #create' do

    context 'with logged in user' do

      let(:user) { create(:user) }

      before do
        login_user user
      end

      context 'with valid attribute' do

        subject {
          Proc.new { post :create, text: "aaa", image: "aaa.jpeg" }
        }

        it 'renders the :create template' do
          subject.call
          expect(response).to render_template :create
        end

        it 'saves the new tweet in the database' do
          expect{ subject.call }.to change(Tweet, :count).by(1)
        end
      end

      context 'with invalid attribute' do

        subject {
          Proc.new { post :create, text: "", image: "" }
        }

        it 'renders the :new template' do
          subject.call
          expect(response).to render_template :new
        end

        it "doesn't save the new tweet in the database" do
          expect{ subject.call }.not_to change(Tweet, :count)
        end

        it 'makes error message to fail to send tweet' do
          subject.call
          expect(flash[:alert]).to eq 'メッセージ送信失敗'
        end
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        post :create
        expect(response).to redirect_to root_path
      end
    end

  end

  describe 'GET #edit' do

    let(:tweet) { create(:tweet) }

    context 'with logged in user' do
      before do
        login_user user
        get :edit, id: tweet
      end

      it "assigns the requested contact to @tweet" do
        expect(assigns(:tweet)).to eq tweet
      end

      it "renders the :edit template" do
        expect(response).to render_template :edit
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        get :edit, id: tweet
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #show' do

    let(:tweet) { create(:tweet) }

    context 'with logged in user' do

      before do
        login_user user
      end

      it "assigns the requested tweet to @tweet" do
        get :show, id: tweet
        expect(assigns(:tweet)).to eq tweet
      end

      it "assigns the requested comments to @comments" do
        get :show, id: tweet
        comments = tweet.comments
        expect(assigns(:comments)).to eq comments
      end

      it "renders the :show template" do
        get :show, id: tweet
        expect(response).to render_template :show
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        get :show, id: tweet
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'DELETE #destroy' do

    let!(:tweet) { create(:tweet, user_id: user.id) }

    context 'with logged in user' do

      before do
        login_user user
      end

      subject {
        Proc.new { delete :destroy, id: tweet }
      }

      context 'tweet.user_id == current_user.id' do

        it "deletes the tweet" do
          expect{
            subject.call
          }.to change(Tweet,:count).by(-1)
        end

        it "renders the :destroy template" do
          subject.call
          expect(response).to render_template :destroy
        end
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        delete :destroy, id: tweet
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'PATCH #update' do

    context 'with logged in user' do

      before do
        login_user user
        patch :update, { id: tweet, text: "hoge", image: "hogehoge.jpeg" }
      end

      context 'tweet.user_id == current_user.id' do

        let(:tweet) { create(:tweet, text: "hoge", image: "hogehoge.jpeg", user_id: user.id) }

        it "changes tweet's attributes" do
          tweet.reload
          expect(tweet.text).to eq("hoge")
          expect(tweet.image).to eq("hogehoge.jpeg")
        end

        it "redirects to articles_path" do
          expect(response).to render_template :update
        end
      end

      context 'tweet.user_id != current_user.id' do

        let(:user2) { create(:user) }
        let(:tweet) { create(:tweet, text: "hoge", image: "hogehoge.jpeg", user_id: user2.id) }

        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end

        it 'makes error message to fail to send tweet' do
          expect(flash[:alert]).to eq '他のユーザーの投稿の編集はできません'
        end
      end
    end

    context 'without logged in user' do
      it 'redirects to tweets#index' do
        tweet = create(:tweet, text: "hoge", image: "hogehoge.jpeg", user_id: user.id)
        patch :update, id: tweet
        expect(response).to redirect_to root_path
      end
    end
  end
end
