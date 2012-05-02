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
  
  describe "PUT update" do
    describe "with valid params" do
      let(:user){ create(:user) }
      before :each do
        User.any_instance.stub(:update_attributes).and_return(true)
      end
      it "authenticates the user" do
        User.any_instance.should_receive(:authenticate)
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}, valid_session
      end
      
      it "redirect to root url" do
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}, valid_session
        response.should render_template("edit")
      end
    end
  end
end
