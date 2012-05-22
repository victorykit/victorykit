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
    let(:user){ create(:user) }
    describe "with valid params" do
      before :each do
        User.any_instance.stub(:update_attributes).and_return(true)
      end
      it "redirect to the root page" do
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}, valid_session
        should redirect_to root_path
      end
    end
    describe "with invalid params" do
      before :each do
        User.any_instance.stub(:update_attributes).and_return(false)
        put :update, {id: user.to_param, user: {bad: "params"}}, valid_session
      end
      it "should render the edit page" do
        response.should render_template("edit")
      end
      it "should assign the user back to the page to show error messages" do
        assigns(:user).should_not be_nil
      end
    end
  end
end
