require 'spec_helper'

describe SignaturesController do
  context "signing a petition" do
    it "should let me sign a petition" do
      petition = Petition.create!(title:"Petition 1")
      post :create, :petition_id => petition.id, :signature => {:name => "Bob", :email => "bob@my.com"}
      petition.signatures[0].name.should eq "Bob"
      petition.signatures[0].email.should eq "bob@my.com"
    end
    
    it "should capture my ip_address and user agent when I sign a petition" do
      petition = Petition.create!(title: "Petition 2")
      post :create, :petition_id => petition.id, :signature => {:name => "Judy", :email => "judy@thoughtworks.com"}
      petition.signatures[0].ip_address.should eq "0.0.0.0"
      petition.signatures[0].user_agent.should eq "Rails Testing"
    end
  end
end
