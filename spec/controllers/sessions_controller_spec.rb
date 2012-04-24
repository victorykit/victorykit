require 'spec_helper'

describe SessionsController do

  describe "POST 'create'" do
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
    context "user attempts to login with wrong password" do
      before(:each) do 
         @user = User.create!(password:"opensesame", password_confirmation: "opensesame", email: "bob@here.com")
         post :create, email: "bob@here.com", password:"closesesame"
      end
      it "renders the login page" do
        response.should render_template :new
      end
      it "does not add user id to the session" do
          session[:user_id].should be_nil
      end
    end
  end

end
