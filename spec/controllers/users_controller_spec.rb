require 'spec_helper'

describe UsersController do
  
  def valid_session
    user = create(:user)
    {:user_id => user.id}
  end
  
  describe "GET index" do
    let(:action){ get :index }
    it_behaves_like "a login protected page"
    it "shows all users" do
      get :index, {}, valid_session
      assigns(:users).should eq([User.find(session[:user_id])])
    end
  end
  
  describe "GET show" do
    let(:user){ create(:user) }
    let(:action){ get :show, {id: user.to_param} }
    it_behaves_like "a login protected page"
    it "shows the requested user" do
      get :show, {:id => user.to_param}, valid_session
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
    let(:user){ create(:user) }
    let(:action){ get :edit, {id: user.to_param} }
    it_behaves_like "a login protected page"
    it "assigns the requested user" do
      get :edit, {:id => user.to_param}, valid_session
      assigns(:user).should eq(user)
    end
  end
  
  describe "PUT update" do
    describe "with valid params" do
      let(:user){ create(:user) }
      let(:action){ put :update, {:id => user.to_param, :user => {'these' => 'params'}} }
      it "updates the requested user" do
        User.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}
      end

      it "assigns the requested user as @user" do
        put :update, {:id => user.to_param}
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        put :update, {:id => user.to_param}
        response.should redirect_to(user)
      end
    end

    describe "with invalid params" do
      let(:user){ create(:user) }
      let(:action){ put :update, {:id => user.to_param, :user => {}} }
      it "assigns the user as @user" do
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => {}}
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => {}}
        response.should render_template("edit")
      end
    end
  end
end
