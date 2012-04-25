require 'spec_helper'

describe UsersController do
  
  describe "GET index" do
    it "shows all users" do
      user = create(:user)
      get :index
      assigns(:users).should eq([user])
    end
  end
  
  describe "GET show" do
    it "shows the requested user" do
      user = create(:user)
      get :show, {:id => user.to_param}
      assigns(:user).should eq(user)
    end
  end
  
  describe "GET new" do
    it "assigns a new user" do
      get :new
      assigns(:user).should be_a_new(User)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested user" do
      user = create(:user)
      get :edit, {:id => user.to_param}
      assigns(:user).should eq(user)
    end
  end
  
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        user = create(:user)
        User.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}
      end

      it "assigns the requested user as @user" do
        user = create(:user)
        put :update, {:id => user.to_param}
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        user = create(:user, password:"opensesame")
        put :update, {:id => user.to_param}
        response.should redirect_to(user)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = create(:user)
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => {}}
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        user = create(:user)
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => {}}
        response.should render_template("edit")
      end
    end
  end
end
