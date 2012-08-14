require 'spec_helper'

describe MembersController do
  it "creates a member" do
    post :create, {:member => {:email => "foo@bar.com", first_name: "Foobar", last_name: "Saunders"}}
    Member.where(email: "foo@bar.com").count.should == 1
  end
  it "does not allow two members with the same email" do
    post :create, {:member => {:email => "foo@bar.com", first_name: "Foobar", last_name: "Saunders"}}
    post :create, {:member => {:email => "foo@bar.com", first_name: "Foobar", last_name: "Wibblechops"}}
    Member.where(email: "foo@bar.com").count.should == 1
    Member.find_by_email("foo@bar.com").full_name.should == "Foobar Saunders"
  end
  it "creates a subscription" do
    post :create, {:member => {:email => "foo@bar.com", first_name: "Foobar", last_name: "Saunders"}}
    Member.find_by_email("foo@bar.com").subscribes.count.should == 1
  end
  it "redirects to the home page" do
    post :create, {:member => {:email => "foo@bar.com", first_name: "Foobar", last_name: "Saunders"}}
    response.should redirect_to root_url
  end
end
