require 'spec_helper'

describe ApplicationController do
  describe "Current User" do
    context "user is in session" do
      before(:each) do 
         @user = create(:user)
         session[:user_id] = @user.id
      end
      its(:current_user) { should == @user }
    end    
    context "user is not in session" do
      before(:each) do 
         session[:user_id] = nil
      end
      its(:current_user) {should be_nil}
    end
  end
end
