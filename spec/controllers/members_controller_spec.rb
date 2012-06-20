require 'spec_helper'

describe MembersController do
	it "creates a member" do
		post :create, {:member => {:email => "foo@bar.com", name: "Foobar Saunders"}}
    Member.where(email: "foo@bar.com").count.should == 1
	end
	it "creates a subscription" do
		post :create, {:member => {:email => "foo@bar.com", name: "Foobar Saunders"}}
    Member.find_by_email("foo@bar.com").subscribes.count.should == 1
	end
	it "redirects to the home page" do
		post :create, {:member => {:email => "foo@bar.com", name: "Foobar Saunders"}}
		response.should redirect_to root_url
	end
end
