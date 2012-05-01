require 'spec_helper'

describe UsersController do
  
  describe "GET new" do
    it "assigns a new user" do
      get :new
      assigns(:user).should be_a_new(User)
    end
  end
  
  describe "Sign up new user" do
    it "logs the user in after signing up" do
      post :create, {:user => {:email => "me@my.com", :password => "password", :password_confirmation => "password"}}
      new_user = User.find_by_email "me@my.com"
      session[:user_id].should eq new_user.id
    end
  end
  
end
