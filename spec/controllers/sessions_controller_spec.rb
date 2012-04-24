require 'spec_helper'

describe SessionsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
    context "user logs in with valid credentials" do
      before(:each) do 
         @user = User.create!(password:"opensesame", password_confirmation: "opensesame", email: "bob@here.com")
         post :create, email: "bob@here.com", password:"opensesame"
      end
      it "adds the user id to the session" do
        session[:user_id].should == @user.id
      end
      it { should redirect_to root_path }
    end
  end

end
