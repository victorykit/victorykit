describe SessionsController do

  pending "Disabled after switching to Devise. Should be deleted or fixed..."

#   describe "POST 'create'" do
#     context "user logs in with valid credentials" do
#       before(:each) do
#          @user = create(:user, password:"opensesame", email: "bob@here.com")
#          post :create, user_session: { email: "bob@here.com", password:"opensesame"}
#       end
#       it "adds the user id to the session" do
# #        session[:user_id].should == @user.id
#         current_user.id.should == @user.id
#       end
#       it { should redirect_to admin_dashboard_path }
#     end
#     context "user attempts to login with wrong password" do
#       before(:each) do
#          @user = create(:user, email: "bob@here.com", password: "supersecret")
#          post :create, new_session: {email: "bob@here.com", password:"closesesame"}
#       end
#       it "redirects to the login page" do
#         response.should redirect_to login_path
#       end
#       it "does not add user id to the session" do
# #        session[:user_id].should be_nil
#         current_user.should be_nil
#       end
#       it "displays message to user" do
#           flash.now[:error].should == "Invalid username or password"
#       end
#     end
#     context "user attempts to login with wrong email" do
#       before(:each) do
#         @user = create(:user, email:"bob@ajob.com", password: "opensesame")
#          post :create, new_session: {email: "jim@here.com", password:"opensesame"}
#       end
#       it "redirects to the login page" do
#         response.should redirect_to login_path
#       end
#       it "does not add user id to the session" do
# #        session[:user_id].should be_nil
#         current_user.should be_nil
#       end
#       it "displays message to user" do
#           flash.now[:error].should == "Invalid username or password"
#       end
#     end
#   end

#   describe "DELETE 'destroy'" do
#     context "user logs out" do
#       before(:each) do
#         @user = create(:user)
#         session[:user_id] = @user.id
#         delete "destroy", :id => @user.id
#       end
#       it "resets session" do
#         session[:user_id].should be_nil
#       end
#       it { should redirect_to root_path }
#       it "displays message logged out message to user" do
#           flash.now[:notice].should == "Logged out!"
#       end
#     end
#   end
end
