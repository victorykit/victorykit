describe Admin::UsersController do

  describe "GET index" do
    let(:action){ get :index }
    it_behaves_like "a super-user only resource page"
    it "shows all users" do
      get :index, {}, valid_super_user_session
      assigns(:users).should eq([User.find(session[:user_id])])
    end
  end

  describe "GET edit" do
    let(:user){ create(:user) }
    let(:action){ get :edit, {id: user.to_param} }
    it_behaves_like "a super-user only resource page"
    it "assigns the requested user" do
      get :edit, {:id => user.to_param}, valid_super_user_session
      assigns(:user).should eq(user)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:user){ create(:user) }
      let(:action){ put :update, {:id => user.to_param} }

      before :each do
        User.any_instance.stub(:update_attributes).and_return(true)
      end
      
      it "updates the requested user" do
        User.any_instance.should_receive(:update_attributes).with({'these' => 'params'}, :as=>:admin)
        put :update, {:id => user.to_param, :user => {'these' => 'params'}}, valid_super_user_session
      end

      it "assigns the requested user as @user" do
        put :update, {:id => user.to_param}, valid_super_user_session
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        put :update, {:id => user.to_param}, valid_super_user_session
        response.should redirect_to(admin_users_url)
      end

    end

    describe "with invalid params" do
      let(:user){ create(:user) }
      let(:action){ put :update, {:id => user.to_param, :user => {}} }
      before :each do
        User.any_instance.stub(:update_attributes).and_return(false)
      end
      it "assigns the user as @user" do
        put :update, {:id => user.to_param, :user => {}}, valid_super_user_session
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => user.to_param, :user => {}}, valid_super_user_session
        response.should render_template("edit")
      end
    end

    describe "updating roles" do
      let(:user){ create(:user) }
      
      it "skips validation" do
        put :update, {:id => user.to_param, :user => {:is_admin => true}}, valid_super_user_session
        user.reload
        user.is_admin.should eq(true)
      end
    end
  end
end
